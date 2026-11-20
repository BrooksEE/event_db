// The setup page every kiosk starts from: pick the race and type its PIN,
// then the kiosk's own settings, then Start (see kiosk.dart).
//
// The screen using it holds the race and PIN ([KioskSetup.race]) and its
// settings; this lays them out the same way for every kiosk. A race
// remembered from last time is shown, and its PIN asked for straight away -
// a kiosk's PIN is never remembered (RacePinCheck.notRemembered).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'kiosk.dart';
import 'race_picker.dart';

class KioskSetup extends StatefulWidget {
  /// The app bar's title: "Results Kiosk".
  final String title;

  /// A line on what the kiosk does, above the race.
  final String? intro;

  final RacePinCheck pinCheck;

  /// Only races with result cards.
  final bool cardsOnly;

  /// The race open now (its PIN checked), or null.
  final PickedRace? race;

  /// A race remembered from last time: shown, with its PIN asked for on
  /// opening, until [race] is set.
  final RaceChoice? lastRace;

  /// A race was opened.
  final ValueChanged<PickedRace> onRace;

  /// The kiosk's own settings, shown once a race is open.
  final List<Widget> settings;

  /// Whether leaving takes the PIN; null shows no switch (it always does).
  final bool? requirePin;
  final ValueChanged<bool>? onRequirePin;

  /// Where the kiosk's orientation is kept; null: no choice offered.
  final String? orientationKey;

  final String startLabel;

  /// Null while it can't start; [notReady] says why.
  final VoidCallback? onStart;
  final String? notReady;

  /// An error about the race, shown under its field.
  final String? error;

  /// Loading the race's details after it was opened.
  final bool busy;

  const KioskSetup({
    super.key,
    required this.title,
    this.intro,
    required this.pinCheck,
    this.cardsOnly = false,
    required this.race,
    this.lastRace,
    required this.onRace,
    this.settings = const [],
    this.requirePin,
    this.onRequirePin,
    this.orientationKey,
    this.startLabel = "Start kiosk",
    required this.onStart,
    this.notReady,
    this.error,
    this.busy = false,
  });

  @override
  State<KioskSetup> createState() => _KioskSetupState();
}

class _KioskSetupState extends State<KioskSetup> {
  KioskOrientation? _orientation;
  String? _unlockError;

  @override
  void initState() {
    super.initState();
    final key = widget.orientationKey;
    if (key != null) {
      KioskOrientation.load(key).then((o) {
        if (mounted) setState(() => _orientation = o);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _openLast());
  }

  /// Asks for the PIN of the race remembered from last time.
  Future<void> _openLast() async {
    final last = widget.lastRace;
    if (widget.race != null || last == null || !mounted) return;
    try {
      final opened = await unlockRace(context, widget.pinCheck, last);
      if (opened != null && mounted) widget.onRace(opened);
    } on RaceUnlockError catch (e) {
      if (mounted) setState(() => _unlockError = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final race = widget.race;
    final shown = race?.race ?? widget.lastRace;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              if (widget.intro != null) ...[
                Text(widget.intro!, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
              ],
              _step(theme, 1, "Race", race == null ? "Pick the race, then enter its ${widget.pinCheck.title}." : null),
              RacePicker(
                selectedId: shown?.id,
                selectedName: shown?.name,
                pinCheck: widget.pinCheck,
                cardsOnly: widget.cardsOnly,
                errorText: widget.error ?? _unlockError,
                busy: widget.busy,
                onPicked: (p) {
                  setState(() => _unlockError = null);
                  widget.onRace(p);
                },
              ),
              if (race == null && widget.lastRace != null && !widget.busy)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.lock_open),
                    label: Text("Enter the ${widget.pinCheck.title}"),
                    onPressed: () {
                      setState(() => _unlockError = null);
                      _openLast();
                    },
                  ),
                ),
              if (race != null) ...[
                const SizedBox(height: 24),
                if (widget.settings.isNotEmpty) ...[
                  _step(theme, 2, "Setup", null),
                  ...widget.settings,
                  const SizedBox(height: 16),
                ],
                _step(theme, widget.settings.isEmpty ? 2 : 3, "Lock", null),
                if (widget.requirePin != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Require PIN to exit"),
                    subtitle: Text(widget.requirePin!
                        ? "Leaving or changing the setup asks for the ${widget.pinCheck.title}"
                        : "Leaving takes a long press and a confirm; changing the setup still asks for the PIN"),
                    value: widget.requirePin!,
                    onChanged: widget.onRequirePin,
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock),
                    title: Text("Leaving or changing the setup asks for the ${widget.pinCheck.title}"),
                  ),
                if (widget.orientationKey != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.screen_rotation),
                    title: const Text("Orientation"),
                    trailing: DropdownButton<KioskOrientation>(
                      value: _orientation ?? KioskOrientation.auto,
                      items: [for (final o in KioskOrientation.values) DropdownMenuItem(value: o, child: Text(o.label))],
                      onChanged: (o) {
                        if (o == null) return;
                        setState(() => _orientation = o);
                        o.save(widget.orientationKey!);
                      },
                    ),
                  ),
                if (_lockTip != null)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: theme.colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: Icon(Icons.phonelink_lock, color: theme.colorScheme.onSecondaryContainer),
                      title: Text("Keep it in this app", style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                      subtitle: Text(_lockTip!, style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    key: const Key("kiosk.start"),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(widget.startLabel, style: const TextStyle(fontSize: 18)),
                    onPressed: widget.onStart,
                  ),
                ),
                if (widget.onStart == null && widget.notReady != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(widget.notReady!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _step(ThemeData theme, int n, String title, String? help) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 12, backgroundColor: theme.colorScheme.primary, child: Text("$n", style: TextStyle(fontSize: 13, color: theme.colorScheme.onPrimary))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (help != null) Text(help, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ),
        ]),
      );

  /// How to stop anyone leaving the app: the lock can't stop Home or the
  /// app switcher, only the device can.
  String? get _lockTip {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => "This lock can't stop the Home gesture. Turn on Guided Access (Settings > Accessibility > Guided Access), then triple-click the side button once the kiosk is running.",
      TargetPlatform.android => "This lock can't stop Home or the app switcher. Turn on app pinning (Settings > Security > App pinning), then pin this app from the app switcher once the kiosk is running.",
      _ => null,
    };
  }
}
