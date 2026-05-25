import 'package:flutter_riverpod/legacy.dart';
import '../models/available_medicine.dart';
import '../services/medicine_services.dart';

class MedicineState {
  final List<AvailableMedicine> medicines;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final String? currentSearchQuery;
  final String? currentCategoryFilter;

  MedicineState({
    this.medicines = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.currentSearchQuery,
    this.currentCategoryFilter,
  });

  MedicineState copyWith({
    List<AvailableMedicine>? medicines,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    int? page,
    String? error,
    String? currentSearchQuery,
    String? currentCategoryFilter,
  }) {
    return MedicineState(
      medicines: medicines ?? this.medicines,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      currentCategoryFilter:
          currentCategoryFilter ?? this.currentCategoryFilter,
    );
  }
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  final MedicineService _medicineService;

  MedicineNotifier(this._medicineService) : super(MedicineState());

  Future<void> fetchMedicines({
    String? searchQuery,
    String? categoryFilter,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      hasMore: true,
      currentSearchQuery: searchQuery,
      currentCategoryFilter: categoryFilter,
    );
    try {
      final medicines = await _medicineService.getAllMedicines(
        searchQuery: searchQuery,
        categoryFilter: categoryFilter,
        page: 1,
        limit: 20,
      );
      state = state.copyWith(
        medicines: medicines,
        isLoading: false,
        hasMore:
            medicines.length == 20, // If less than 20 returned, no more items
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreMedicines() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;

    state = state.copyWith(isFetchingMore: true, error: null);

    try {
      final nextPage = state.page + 1;
      final newMedicines = await _medicineService.getAllMedicines(
        searchQuery: state.currentSearchQuery,
        categoryFilter: state.currentCategoryFilter,
        page: nextPage,
        limit: 20,
      );

      state = state.copyWith(
        medicines: [...state.medicines, ...newMedicines],
        isFetchingMore: false,
        page: nextPage,
        hasMore: newMedicines.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }

}
