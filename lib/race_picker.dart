// Race picker: a field that searches races as you type (result/RaceSearch on
// the server) and still takes a race id typed in full.
//
// Anyone can search the public races; a logged-in user also gets their own
// hosts' races, first, including ones not public yet. With the field empty it
// offers the races picked recently on this device. Optionally it checks the
// race's PIN (asking for it, and remembering it per race) before handing the
// race over.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RPC.dart';

/// A race as the picker shows it. Only [id] is certain: a race id typed in
/// full may not be one the search knows.
class RaceChoice {
  final int id;
  final String? name;
  final String? date;
  final String? status;
  final String? hostKey;
  final String? hostName;

  /// One of the user's own hosts' races.
  final bool mine;

  const RaceChoice(this.id, {this.name, this.date, this.status, this.hostKey, this.hostName, this.mine = false});

  factory RaceChoice.fromJson(Map m) => RaceChoice(
        (m["id"] as num).toInt(),
        name: m["name"] as String?,
        date: m["date"] as String?,
        status: m["status"] as String?,
        hostKey: m["host_key"] as String?,
        hostName: m["host_name"] as String?,
        mine: m["mine"] == true,
      );

  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "date": date, "status": status, "host_key": hostKey, "host_name": hostName, "mine": mine};

  /// "2026 Escalante Canyons", or just "168202" when the name isn't known.
  String get label => (name == null || name!.isEmpty) ? "$id" : name!;

  /// "#168202 · 2026-10-10 · Escalante Canyons Marathon, Half & 5K"
  String get details => ["#$id", if (date != null) date!, if (hostName != null) hostName!, if (status != null && status != "Active") status!].join(" · ");
}

/// Searches the races [query] matches (empty for less than 2 characters or
/// 1 digit). [cardsOnly] keeps races that have result cards.
Future<List<RaceChoice>> searchRaces(String query, {bool cardsOnly = false, int limit = 20}) async {
  final q = query.trim();
  if (q.isEmpty || (q.length < 2 && int.tryParse(q) == null)) return const [];
  final r = await RPC().rpc("result", "RaceSearch", "search", {"query": q, "limit": limit, "cards_only": cardsOnly}, null,
      forceLogin: false, retryLogin: false);
  return [for (final m in (r["races"] as List? ?? const [])) RaceChoice.fromJson(m as Map)];
}

/// The race [id], as the search knows it, or null if it doesn't.
Future<RaceChoice?> lookupRace(int id) async {
  try {
    return (await searchRaces("$id", limit: 20)).where((r) => r.id == id).firstOrNull;
  } catch (e) {
    return null;
  }
}

/// The server wants a PIN for the race, or a different one ([RacePinCheck]).
class RacePinRequired implements Exception {
  const RacePinRequired();
}

/// The race can't be opened with any PIN, e.g. none has been set ([message]
/// says why).
class RacePinRefused implements Exception {
  final String message;
  const RacePinRefused(this.message);
  @override
  String toString() => message;
}

/// How the picker checks a race's PIN before handing the race over: [check]
/// tries a PIN (null: none yet) and returns false if there's no such race,
/// throws [RacePinRequired] for a missing or wrong PIN, or [RacePinRefused].
/// PINs that work are remembered per race under [prefsKey].
class RacePinCheck {
  /// What the PIN is called: "Timer PIN".
  final String title;
  final String prefsKey;
  final Future<bool> Function(int raceId, String? pin) check;

  const RacePinCheck({required this.title, required this.prefsKey, required this.check});

  /// The race's timers PIN (result/Timer/check_pin) - the one Race Ops uses,
  /// and stored where it keeps them, so a race unlocked in one is unlocked in
  /// the other.
  static final timers = RacePinCheck(
    title: "Timer PIN",
    prefsKey: "timer.pins",
    check: (raceId, pin) async {
      try {
        final r = await RPC().rpc("result", "Timer", "check_pin", {"race_id": raceId}, null,
            context: {if (pin != null) "timer_pin": pin}, forceLogin: false, retryLogin: false);
        return r["ok"] == true;
      } catch (e) {
        final msg = "$e";
        if (msg.contains("PIN_REQUIRED")) throw const RacePinRequired();
        if (msg.contains("PIN_NOT_SET")) throw const RacePinRefused("This race has no timer PIN set yet. Ask the race director to set one.");
        rethrow;
      }
    },
  );

  Future<Map<String, String>> _pins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Map<String, String>.from(jsonDecode(prefs.getString(prefsKey) ?? "{}"));
    } catch (e) {
      return {};
    }
  }

  /// The PIN remembered for [raceId], if any.
  Future<String?> pinFor(int raceId) async => (await _pins())["$raceId"];

  Future<void> remember(int raceId, String pin) async {
    final pins = await _pins();
    pins["$raceId"] = pin;
    await (await SharedPreferences.getInstance()).setString(prefsKey, jsonEncode(pins));
  }
}

/// What [RacePicker.onPicked] gets: the race, and the PIN that opened it
/// (null without a [RacePinCheck], or when the race needed none).
class PickedRace {
  final RaceChoice race;
  final String? pin;
  const PickedRace(this.race, this.pin);
}

const _recentKey = "race_picker.recent";
const _maxRecent = 8;

Future<List<RaceChoice>> recentRaces() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return [for (final m in jsonDecode(prefs.getString(_recentKey) ?? "[]") as List) RaceChoice.fromJson(m as Map)];
  } catch (e) {
    return const [];
  }
}

Future<void> _rememberRecent(RaceChoice race) async {
  if (race.id <= 0) return;
  final list = [race, ...(await recentRaces()).where((r) => r.id != race.id)].take(_maxRecent).toList();
  try {
    await (await SharedPreferences.getInstance()).setString(_recentKey, jsonEncode([for (final r in list) r.toJson()]));
  } catch (e) {
    // a convenience only
  }
}

/// The race field. Type to search (names, series, hosts, years, or the start
/// of an id), pick from the list - or type a whole race id and press Set.
class RacePicker extends StatefulWidget {
  /// Called once a race is picked (and its PIN, with [pinCheck], checks out).
  final ValueChanged<PickedRace> onPicked;

  /// Called when Set is pressed with the field empty, if clearing the race
  /// means something to the screen.
  final VoidCallback? onCleared;

  /// The race currently chosen, shown in the field (by name once known).
  final int? selectedId;
  final String? selectedName;

  /// Check the race's PIN before [onPicked]; null hands any race straight
  /// over (the screen checks it itself, if at all).
  final RacePinCheck? pinCheck;

  /// Only races with result cards.
  final bool cardsOnly;

  final String label;

  /// An error the screen wants shown under the field.
  final String? errorText;

  /// The screen is busy with the last pick (shows a spinner on Set).
  final bool busy;

  const RacePicker({
    super.key,
    required this.onPicked,
    this.onCleared,
    this.selectedId,
    this.selectedName,
    this.pinCheck,
    this.cardsOnly = false,
    this.label = "Race",
    this.errorText,
    this.busy = false,
  });

  @override
  State<RacePicker> createState() => _RacePickerState();
}

class _RacePickerState extends State<RacePicker> {
  final TextEditingController _c = TextEditingController();
  final FocusNode _focus = FocusNode();

  // What the field was last set to show, so a change of [selectedId] from
  // outside (a link, a restore) updates it but the user's typing isn't
  // overwritten.
  String? _shownFor;

  // The race the field stands for - the one picked or set by the screen -
  // kept while the user types over it, so leaving the field without picking
  // puts it back, and Set on its name doesn't search.
  RaceChoice? _current;

  // Debounce: every change of the text (typed, or set by a pick) bumps
  // this; a search only runs, and its results only count, if nothing newer
  // came in the meantime.
  int _typed = 0;
  List<RaceChoice> _last = const [];

  // The options for the newest text. Every optionsBuilder call resolves to
  // this, so a slow, older search can't reopen the list with stale results.
  Future<List<RaceChoice>> _latest = Future.value(const []);
  bool _searching = false;
  String? _error;
  bool _checking = false;

  static const _debounce = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _showingCurrent => _current != null && _c.text == _current!.label;

  void _selectAll() => _c.selection = TextSelection(baseOffset: 0, extentOffset: _c.text.length);

  void _onFocus() {
    if (_focus.hasFocus) {
      // Focused while showing the race: select it all, so typing replaces it
      // (after the frame - a tap places the cursor once focus has moved).
      if (_showingCurrent) WidgetsBinding.instance.addPostFrameCallback((_) => _showingCurrent ? _selectAll() : null);
      return;
    }
    // Left without picking: show the race again. (Shortly after, so a tap
    // on an option - which may take focus on the way - is picked first.)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || _focus.hasFocus || _checking || _current == null || _showingCurrent) return;
      _typed++;
      setState(() {
        _error = null;
        _c.text = _current!.label;
      });
    });
  }

  void _clear() {
    _typed++;
    _c.clear();
    setState(() => _error = null);
    _focus.requestFocus(); // the empty field offers recent races
  }

  void _syncSelected() {
    final key = "${widget.selectedId}|${widget.selectedName}";
    if (key == _shownFor) return;
    _shownFor = key;
    final id = widget.selectedId;
    if (id == null) {
      _current = null;
      _c.text = "";
    } else if (id == _current?.id && widget.selectedName == null && _current?.name != null) {
      // The screen has the race but not (yet) its name - keep the one picked.
    } else {
      // Keep what's known about the race (date, host) if it's the same one.
      final c = _current;
      _current = c != null && c.id == id
          ? RaceChoice(id, name: widget.selectedName ?? c.name, date: c.date, status: c.status, hostKey: c.hostKey, hostName: c.hostName, mine: c.mine)
          : RaceChoice(id, name: widget.selectedName);
      _typed++;
      _c.text = _current!.label;
    }
  }

  Future<Iterable<RaceChoice>> _options(TextEditingValue value) async {
    final mine = _latest = _resolve(value);
    final found = await mine;
    return identical(mine, _latest) ? found : await _latest;
  }

  Future<List<RaceChoice>> _resolve(TextEditingValue value) async {
    final token = ++_typed;
    final text = value.text.trim();
    if (_current != null && value.text == _current!.label) return const [];
    if (text.isEmpty) return recentRaces();
    await Future.delayed(_debounce);
    if (token != _typed) return const [];
    setState(() => _searching = true);
    try {
      final found = await searchRaces(text, cardsOnly: widget.cardsOnly);
      if (token == _typed) {
        _last = found;
        _error = null;
      }
    } catch (e) {
      if (token == _typed) {
        _last = const [];
        _error = "Search failed: ${e.toString().split("\n").first}";
      }
    } finally {
      if (mounted && token == _typed) setState(() => _searching = false);
    }
    return token == _typed ? _last : const [];
  }

  /// Set: the race whose name is showing, a whole id, or the first match.
  Future<void> _submit() async {
    final text = _c.text.trim();
    if (text.isEmpty) {
      widget.onCleared?.call();
      return;
    }
    final id = int.tryParse(text);
    if (id != null) {
      final known = _last.where((r) => r.id == id).firstOrNull;
      await _pick(known ?? RaceChoice(id));
    } else if (_current != null && text == _current!.label) {
      await _pick(_current!);
    } else if (_last.isNotEmpty) {
      await _pick(_last.first);
    } else {
      setState(() => _error = "Pick a race from the list, or type its race id.");
    }
  }

  Future<void> _pick(RaceChoice race) async {
    _focus.unfocus();
    _typed++; // whatever was being searched for is moot now
    final before = _current; // the race the field stood for until now
    setState(() {
      _error = null;
      _current = race;
      _c.text = race.label;
    });
    String? pin;
    final check = widget.pinCheck;
    if (check != null && race.id > 0) {
      setState(() => _checking = true);
      try {
        pin = await _checkPin(check, race);
      } finally {
        if (mounted) setState(() => _checking = false);
      }
      if (pin == null) {
        // Cancelled, refused, or no such race: nothing was opened, so the
        // field goes back to the race that's still open (the error, if any,
        // says what happened).
        if (mounted) {
          _typed++;
          setState(() {
            _current = before;
            _c.text = before?.label ?? "";
          });
        }
        return;
      }
    }
    // A whole id typed in: fill in its name if the search knows it.
    var picked = race;
    if (race.name == null && race.id > 0) {
      picked = await lookupRace(race.id) ?? race;
      if (mounted && picked.name != null) {
        setState(() {
          _current = picked;
          _c.text = picked.label;
        });
      }
    }
    await _rememberRecent(picked);
    widget.onPicked(PickedRace(picked, pin == "" ? null : pin));
  }

  /// The PIN that opens [race] ("" if it needs none), or null if it can't be
  /// opened (the reason is shown under the field).
  Future<String?> _checkPin(RacePinCheck check, RaceChoice race) async {
    String? pin = await check.pinFor(race.id);
    bool failed = false;
    while (true) {
      try {
        final ok = await check.check(race.id, pin);
        if (!ok) {
          if (mounted) setState(() => _error = "There's no race #${race.id}.");
          return null;
        }
        if (pin != null) await check.remember(race.id, pin);
        return pin ?? "";
      } on RacePinRequired {
        if (!mounted) return null;
        final entered = await _askPin(check, race, failed: failed || pin != null);
        if (entered == null) return null;
        pin = entered;
        failed = true;
      } on RacePinRefused catch (e) {
        if (mounted) setState(() => _error = "${race.label}: ${e.message}");
        return null;
      } catch (e) {
        if (mounted) setState(() => _error = "Couldn't check ${race.label}: ${e.toString().split("\n").first}");
        return null;
      }
    }
  }

  Future<String?> _askPin(RacePinCheck check, RaceChoice race, {required bool failed}) {
    final pinC = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        void submit() {
          if (pinC.text.trim().isNotEmpty) Navigator.pop(context, pinC.text.trim());
        }

        return AlertDialog(
          title: Text("${check.title} Required"),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (failed) Text("Incorrect PIN. Please try again.", style: TextStyle(color: Theme.of(context).colorScheme.error)),
            Text("Enter the ${check.title.toLowerCase()} for ${race.label} (#${race.id})."),
            TextField(controller: pinC, autofocus: true, decoration: InputDecoration(labelText: check.title), onSubmitted: (_) => submit()),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            FilledButton(onPressed: submit, child: const Text("Submit")),
          ],
        );
      },
    ).whenComplete(pinC.dispose);
  }

  @override
  Widget build(BuildContext context) {
    _syncSelected();
    final busy = widget.busy || _checking;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: RawAutocomplete<RaceChoice>(
          textEditingController: _c,
          focusNode: _focus,
          displayStringForOption: (r) => r.label,
          optionsBuilder: _options,
          onSelected: _pick,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: "Name, host, year or race id",
              errorText: _error ?? widget.errorText,
              errorMaxLines: 3,
              suffixIcon: _searching
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                  : ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => controller.text.isEmpty
                          ? const Icon(Icons.search)
                          : IconButton(tooltip: "Clear", icon: const Icon(Icons.clear), onPressed: _clear),
                    ),
            ),
            textInputAction: TextInputAction.search,
            onTap: () {
              if (_showingCurrent) _selectAll();
            },
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          // Nothing while the field shows the chosen race: the autocomplete
          // keeps the last results open after a pick while the field has focus.
          optionsViewBuilder: (context, onSelected, options) =>
              _showingCurrent ? const SizedBox.shrink() : _Options(options: options.toList(), onSelected: onSelected, recent: _c.text.trim().isEmpty),
        ),
      ),
      const SizedBox(width: 8),
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: FilledButton(
          onPressed: busy ? null : _submit,
          child: busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Set"),
        ),
      ),
    ]);
  }
}

class _Options extends StatelessWidget {
  final List<RaceChoice> options;
  final AutocompleteOnSelected<RaceChoice> onSelected;

  /// Showing recent races (the field is empty), not search results.
  final bool recent;
  const _Options({required this.options, required this.onSelected, required this.recent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320, maxWidth: 420),
          child: ListView(padding: EdgeInsets.zero, shrinkWrap: true, children: [
            if (recent)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text("Recent", style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
            for (final r in options)
              ListTile(
                dense: true,
                title: Text(r.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(r.details, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: r.mine ? Tooltip(message: "One of your races", child: Icon(Icons.star, size: 18, color: theme.colorScheme.secondary)) : null,
                onTap: () => onSelected(r),
              ),
          ]),
        ),
      ),
    );
  }
}
