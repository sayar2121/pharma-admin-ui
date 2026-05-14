import 'package:flutter_riverpod/legacy.dart';

class SettingsState {
  final bool isLoading;
  final String? error;

  SettingsState({
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
