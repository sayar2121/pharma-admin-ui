import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/settings_notifier.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
