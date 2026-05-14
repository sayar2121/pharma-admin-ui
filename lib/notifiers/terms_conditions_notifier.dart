import 'package:flutter_riverpod/legacy.dart';
import '../models/terms_conditions.dart';
import '../services/terms_conditions_services.dart';

class TermsConditionsState {
  final List<TermsConditionsModel> termsList;
  final bool isLoading;
  final String? error;

  TermsConditionsState({
    this.termsList = const [],
    this.isLoading = false,
    this.error,
  });

  TermsConditionsState copyWith({
    List<TermsConditionsModel>? termsList,
    bool? isLoading,
    String? error,
  }) {
    return TermsConditionsState(
      termsList: termsList ?? this.termsList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TermsConditionsNotifier extends StateNotifier<TermsConditionsState> {
  final TermsConditionsServices _services;

  TermsConditionsNotifier(this._services) : super(TermsConditionsState()) {
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _services.getAllTermsConditions();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final list = data.map((e) => TermsConditionsModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, termsList: list);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? 'Failed to fetch terms and conditions',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
