// Kiosk: a screen handed to volunteers or the public, locked so they can use
// it but not leave it or change its setup.
//
// [KioskShell] wraps the running screen. Back, and a long press on the
// top-left corner, open the unlock prompt: the PIN the setup person entered
// (or, with requirePin off, a confirm). Unlocked, a menu offers the kiosk's
// own actions, Change setup, Orientation and Exit; left alone it closes and
// the kiosk stays locked. While it runs the screen stays awake and full
// screen, in the orientation chosen for it.
//
// The PIN is compared on the device, so a kiosk that has lost its network
// can still be left.
//
// The route holding a KioskShell is popped with a [KioskExit]: [runKiosk]
// pushes it from a setup screen and leaves that too on Exit.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Whether [entered] matches one of [pins], as the server compares them:
/// trimmed, and ignoring case.
bool pinMatches(String entered, Iterable<String?> pins) {
  final e = entered.trim().toLowerCase();
  return e.isNotEmpty && pins.any((p) => p != null && p.trim().toLowerCase() == e);
}

/// How a kiosk was left.
enum KioskExit {
  /// Back to the setup screen it was started from.
  changeSetup,

  /// Out of the tool altogether.
  exit,
}

/// Which way a kiosk's screen is turned.
enum KioskOrientation {
  auto("Auto"),
  portrait("Portrait"),
  landscape("Landscape"),
  landscapeFlipped("Landscape flipped");

  final String label;
  const KioskOrientation(this.label);

  List<DeviceOrientation> get deviceOrientations => switch (this) {
        KioskOrientation.auto => DeviceOrientation.values,
        KioskOrientation.portrait => [DeviceOrientation.portraitUp],
        KioskOrientation.landscape => [DeviceOrientation.landscapeLeft],
        KioskOrientation.landscapeFlipped => [DeviceOrientation.landscapeRight],
      };

  /// The one saved under [prefsKey] (auto if none).
  static Future<KioskOrientation> load(String prefsKey) async {
    try {
      final name = (await SharedPreferences.getInstance()).getString(prefsKey);
      return values.where((o) => o.name == name).firstOrNull ?? auto;
    } catch (e) {
      return auto;
    }
  }

  Future<void> save(String prefsKey) async {
    try {
      await (await SharedPreferences.getInstance()).setString(prefsKey, name);
    } catch (e) {
      // a convenience only
    }
  }
}

/// Something the unlocked menu offers besides the built-in items.
class KioskAction {
  final String label;
  final IconData icon;
  final FutureOr<void> Function() onSelected;

  /// Asks for the PIN first when the menu was opened with a confirm only.
  final bool needsPin;

  const KioskAction(this.label, this.icon, this.onSelected, {this.needsPin = false});
}

/// The orientation the rest of the app runs in, put back when a kiosk ends.
List<DeviceOrientation> kioskAppOrientations = [DeviceOrientation.portraitUp];

class KioskShell extends StatefulWidget {
  final Widget child;

  /// Any of these unlocks it (null and empty ones are ignored).
  final List<String?> pins;

  /// Off, or with no [pins]: a long press and a confirm open the menu.
  final bool requirePin;

  /// Shown at the top of the menu: "Results Kiosk".
  final String title;

  /// The kiosk's own menu items, first.
  final List<KioskAction> actions;

  /// Offer Change setup (pops with [KioskExit.changeSetup]); it needs the
  /// PIN even when the menu doesn't.
  final bool offerChangeSetup;
  final String changeSetupLabel;

  /// Where the chosen orientation is kept; with it the menu offers
  /// Orientation. Null leaves the orientation alone.
  final String? orientationKey;

  /// Change setup and Exit; by default the route is popped with the choice.
  /// For a kiosk that runs on the same screen as its setup.
  final void Function(KioskExit how)? onExit;

  /// Back while the kiosk has something of its own to close (a participant
  /// open, the camera): true if it was handled, so the menu isn't opened.
  final bool Function()? onBack;

  /// How long "Long-press this corner for the menu" shows at the start.
  final Duration hintFor;

  /// The menu and PIN prompt close themselves after this long untouched.
  final Duration idleClose;

  const KioskShell({
    super.key,
    required this.child,
    required this.title,
    this.pins = const [],
    this.requirePin = true,
    this.actions = const [],
    this.offerChangeSetup = true,
    this.changeSetupLabel = "Change setup",
    this.orientationKey,
    this.onExit,
    this.onBack,
    this.hintFor = const Duration(seconds: 6),
    this.idleClose = const Duration(seconds: 30),
  });

  @override
  State<KioskShell> createState() => KioskShellState();
}

class KioskShellState extends State<KioskShell> {
  bool _hint = true;
  Timer? _hintTimer;
  bool _menuOpen = false;
  bool _wasAwake = false;

  List<String> get _pins => [for (final p in widget.pins) if (p != null && p.trim().isNotEmpty) p];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _keepAwake();
    final key = widget.orientationKey;
    if (key != null) KioskOrientation.load(key).then(_apply);
    _hintTimer = Timer(widget.hintFor, () {
      if (mounted) setState(() => _hint = false);
    });
  }

  Future<void> _keepAwake() async {
    try {
      _wasAwake = await WakelockPlus.enabled;
      await WakelockPlus.enable();
    } catch (e) {
      // not on every platform
    }
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    if (!_wasAwake) WakelockPlus.disable().catchError((_) {});
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    if (widget.orientationKey != null) SystemChrome.setPreferredOrientations(kioskAppOrientations);
    super.dispose();
  }

  void _apply(KioskOrientation o) {
    if (mounted) SystemChrome.setPreferredOrientations(o.deviceOrientations);
  }

  /// Opens the menu, behind the PIN (or a confirm). Also what Back and the
  /// corner do.
  Future<void> openMenu() async {
    if (_menuOpen) return;
    _menuOpen = true;
    try {
      final needPin = widget.requirePin && _pins.isNotEmpty;
      final ok = needPin ? await askPin() : await _confirm();
      if (!ok || !mounted) return;
      final choice = await _timed<Object>((context) => SimpleDialog(
            title: Text(widget.title),
            children: [
              for (final a in widget.actions) _option(context, a, a.icon, a.label),
              if (widget.offerChangeSetup) _option(context, KioskExit.changeSetup, Icons.settings, widget.changeSetupLabel),
              if (widget.orientationKey != null) _option(context, "orientation", Icons.screen_rotation, "Orientation"),
              _option(context, KioskExit.exit, Icons.exit_to_app, "Exit"),
              _option(context, "resume", Icons.play_arrow, "Resume"),
            ],
          ));
      if (!mounted || choice == null || choice == "resume") return;
      if (choice == "orientation") {
        await _pickOrientation();
        return;
      }
      final pinFirst = !needPin && _pins.isNotEmpty && (choice == KioskExit.changeSetup || (choice is KioskAction && choice.needsPin));
      if (pinFirst && !await askPin()) return;
      if (!mounted) return;
      if (choice is KioskAction) {
        await choice.onSelected();
      } else if (choice is KioskExit) {
        final onExit = widget.onExit;
        if (onExit != null) {
          onExit(choice);
        } else {
          Navigator.of(context).pop(choice);
        }
      }
    } finally {
      _menuOpen = false;
    }
  }

  Widget _option(BuildContext context, Object value, IconData icon, String label) => SimpleDialogOption(
        key: Key("kiosk.menu.$label"),
        onPressed: () => Navigator.pop(context, value),
        child: ListTile(leading: Icon(icon), title: Text(label)),
      );

  Future<bool> _confirm() async {
    final ok = await _timed<bool>((context) => AlertDialog(
          title: const Text("Open the menu?"),
          content: const Text("The kiosk keeps running behind it."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("Open")),
          ],
        ));
    return ok == true;
  }

  /// Asks for one of the PINs; true once one matches.
  Future<bool> askPin() async {
    final c = TextEditingController();
    String? err;
    var visible = false;
    final ok = await _timed<bool>((context) => StatefulBuilder(builder: (context, setDlg) {
          void check() {
            if (pinMatches(c.text, _pins)) {
              Navigator.pop(context, true);
            } else {
              setDlg(() => err = "Wrong PIN");
            }
          }

          return AlertDialog(
            title: const Text("PIN for the menu"),
            content: TextField(
              key: const Key("kiosk.pin"),
              controller: c,
              autofocus: true,
              obscureText: !visible,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: "PIN",
                errorText: err,
                suffixIcon: IconButton(
                  tooltip: visible ? "Hide PIN" : "Show PIN",
                  icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setDlg(() => visible = !visible),
                ),
              ),
              onSubmitted: (_) => check(),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              FilledButton(onPressed: check, child: const Text("Unlock")),
            ],
          );
        }));
    return ok == true;
  }

  Future<void> _pickOrientation() async {
    final key = widget.orientationKey!;
    final current = await KioskOrientation.load(key);
    if (!mounted) return;
    final o = await _timed<KioskOrientation>((context) => SimpleDialog(
          title: const Text("Orientation"),
          children: [
            for (final o in KioskOrientation.values)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, o),
                child: ListTile(
                  leading: Icon(o == current ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  title: Text(o.label),
                ),
              ),
          ],
        ));
    if (o == null) return;
    await o.save(key);
    _apply(o);
  }

  /// A dialog that closes itself (null) after [KioskShell.idleClose]
  /// untouched, so an unlocked menu isn't left for the next person.
  Future<T?> _timed<T>(WidgetBuilder builder) => showDialog<T>(
        context: context,
        builder: (context) => _IdleClose(after: widget.idleClose, child: builder(context)),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Back opens the menu, unless the kiosk has a use for it
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (widget.onBack?.call() == true) return;
        openMenu();
      },
      child: Stack(children: [
        Positioned.fill(child: widget.child),
        // the way out: a long press here
        Positioned(
          left: 0,
          top: 0,
          width: 64,
          height: 64,
          child: GestureDetector(
            key: const Key("kiosk.corner"),
            behavior: HitTestBehavior.translucent,
            onLongPress: openMenu,
          ),
        ),
        if (_hint)
          Positioned(
            left: 12,
            top: 12,
            child: IgnorePointer(
              child: SafeArea(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text("Long-press this corner for the menu", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// Pops its route after [after] with no touch inside it.
class _IdleClose extends StatefulWidget {
  final Duration after;
  final Widget child;
  const _IdleClose({required this.after, required this.child});

  @override
  State<_IdleClose> createState() => _IdleCloseState();
}

class _IdleCloseState extends State<_IdleClose> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _t?.cancel();
    _t = Timer(widget.after, () {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _restart(),
        child: widget.child,
      );
}

/// Runs the kiosk [builder] makes, from its setup screen: Change setup comes
/// back here, Exit (or the route popped any other way but Change setup)
/// leaves the setup screen too.
Future<void> runKiosk(BuildContext context, WidgetBuilder builder) async {
  final result = await Navigator.of(context).push<KioskExit>(MaterialPageRoute(builder: builder));
  if (result == KioskExit.exit && context.mounted) Navigator.of(context).pop();
}
