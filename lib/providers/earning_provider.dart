import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/earning.dart';
import '../services/earning_services.dart';
import 'auth_provider.dart';

class EarningState {
  final List<EarningModel> earnings;
  final EarningSummary? summary;
  final bool isLoading;
  final String? error;

  EarningState({
    this.earnings = const [],
    this.summary,
    this.isLoading = false,
    this.error,
  });

  EarningState copyWith({
    List<EarningModel>? earnings,
    EarningSummary? summary,
    bool? isLoading,
    String? error,
  }) {
    return EarningState(
      earnings: earnings ?? this.earnings,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final earningServiceProvider = Provider((ref) => EarningService());

final earningProvider = StateNotifierProvider<EarningNotifier, EarningState>((ref) {
  return EarningNotifier(ref.read(earningServiceProvider), ref);
});

class EarningNotifier extends StateNotifier<EarningState> {
  final EarningService _service;
  final Ref _ref;

  EarningNotifier(this._service, this._ref) : super(EarningState()) {
    fetchEarningsData();
  }

  Future<void> fetchEarningsData() async {
    final shopId = _ref.read(authProvider).user?.shopId;
    if (shopId == null) {
      state = state.copyWith(error: "Shop ID not available", isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final summary = await _service.fetchEarningSummary(shopId);
      final earnings = await _service.fetchEarnings(shopId, limit: 100);

      state = state.copyWith(
        summary: summary,
        earnings: earnings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
