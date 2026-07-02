import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _languageKey = 'app_language';

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  static const _importedCalendarEventsKey = 'imported_calendar_event_ids';

  Future<Set<String>> getImportedCalendarEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_importedCalendarEventsKey)?.toSet() ?? {};
  }

  Future<void> markCalendarEventsImported(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_importedCalendarEventsKey)?.toSet() ?? {};
    current.addAll(ids);
    await prefs.setStringList(_importedCalendarEventsKey, current.toList());
  }
}

final settingsStorageProvider = Provider<SettingsStorage>((ref) => SettingsStorage());
