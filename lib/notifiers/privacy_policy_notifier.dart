import 'package:flutter_riverpod/legacy.dart';
import '../models/privacy_policy.dart';
import '../services/privacy_policy_services.dart';

class PrivacyPolicyState {
  final List<PrivacyPolicyModel> policiesList;
  final bool isLoading;
  final String? error;

  PrivacyPolicyState({
    this.policiesList = const [],
    this.isLoading = false,
    this.error,
  });

  PrivacyPolicyState copyWith({
    List<PrivacyPolicyModel>? policiesList,
    bool? isLoading,
    String? error,
  }) {
    return PrivacyPolicyState(
      policiesList: policiesList ?? this.policiesList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PrivacyPolicyNotifier extends StateNotifier<PrivacyPolicyState> {
  final PrivacyPolicyServices _services;

  PrivacyPolicyNotifier(this._services) : super(PrivacyPolicyState()) {
    fetchPolicies();
  }

  Future<void> fetchPolicies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _services.getAllPrivacyPolicies();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final list = data.map((e) => PrivacyPolicyModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, policiesList: list);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? 'Failed to fetch privacy policies',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
