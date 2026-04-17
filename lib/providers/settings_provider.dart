import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late SharedPreferences _prefs;
  static const _onboardingKey = 'show_onboarding';
  static const _darkModeKey = 'is_dark_mode';
  static const _autoCleanEnabledKey = 'is_auto_clean_enabled';
  static const _autoCleanDaysKey = 'auto_clean_days';

  @override
  FutureOr<SettingsState> build() async {
    _prefs = await SharedPreferences.getInstance();
    return SettingsState(
      showOnboarding: _prefs.getBool(_onboardingKey) ?? true,
      isDarkMode: _prefs.getBool(_darkModeKey) ?? false,
      isAutoCleanEnabled: _prefs.getBool(_autoCleanEnabledKey) ?? true,
      autoCleanDays: _prefs.getInt(_autoCleanDaysKey) ?? 30,
    );
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, false);
    state = AsyncValue.data(state.value!.copyWith(showOnboarding: false));
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.value!.isDarkMode;
    await _prefs.setBool(_darkModeKey, newValue);
    state = AsyncValue.data(state.value!.copyWith(isDarkMode: newValue));
  }

  Future<void> toggleAutoClean() async {
    final newValue = !state.value!.isAutoCleanEnabled;
    await _prefs.setBool(_autoCleanEnabledKey, newValue);
    state = AsyncValue.data(state.value!.copyWith(isAutoCleanEnabled: newValue));
  }

  Future<void> setAutoCleanDays(int days) async {
    await _prefs.setInt(_autoCleanDaysKey, days);
    state = AsyncValue.data(state.value!.copyWith(autoCleanDays: days));
  }
}

class SettingsState {
  final bool showOnboarding;
  final bool isDarkMode;
  final bool isAutoCleanEnabled;
  final int autoCleanDays;

  SettingsState({
    required this.showOnboarding,
    required this.isDarkMode,
    required this.isAutoCleanEnabled,
    required this.autoCleanDays,
  });

  SettingsState copyWith({
    bool? showOnboarding,
    bool? isDarkMode,
    bool? isAutoCleanEnabled,
    int? autoCleanDays,
  }) {
    return SettingsState(
      showOnboarding: showOnboarding ?? this.showOnboarding,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isAutoCleanEnabled: isAutoCleanEnabled ?? this.isAutoCleanEnabled,
      autoCleanDays: autoCleanDays ?? this.autoCleanDays,
    );
  }
}
