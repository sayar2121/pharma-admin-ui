import 'package:flutter_riverpod/legacy.dart';
import '../models/available_medicine.dart';
import '../models/medicine_inventory.dart';
import '../services/medicine_services.dart';

class MedicineState {
  final List<AvailableMedicine> medicines;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final List<MedicineInventory> inventory;
  final List<MedicineInventory> filteredInventory;
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
    this.inventory = const [],
    this.filteredInventory = const [],
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
    List<MedicineInventory>? inventory,
    List<MedicineInventory>? filteredInventory,
  }) {
    return MedicineState(
      medicines: medicines ?? this.medicines,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      currentCategoryFilter: currentCategoryFilter ?? this.currentCategoryFilter,
      inventory: inventory ?? this.inventory,
      filteredInventory: filteredInventory ?? this.filteredInventory,
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
        hasMore: medicines.length == 20, // If less than 20 returned, no more items
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

  // Inventory Methods
  Future<void> fetchInventory(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final inventory = await _medicineService.getShopInventory(shopId);
      state = state.copyWith(
        inventory: inventory,
        filteredInventory: inventory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void searchInventory(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredInventory: state.inventory);
    } else {
      final filtered = state.inventory.where((item) {
        final name = item.medicine?.medicineName.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
      state = state.copyWith(filteredInventory: filtered);
    }
  }

  Future<void> addToInventory({
    required String shopId,
    required String medicineId,
    required double discountPercent,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _medicineService.addToInventory(
        shopId: shopId,
        medicineId: medicineId,
        discountPercent: discountPercent,
        status: status,
      );
      // Refresh inventory
      await fetchInventory(shopId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateInventoryItem({
    required String shopId,
    required String inventoryId,
    double? discountPercent,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _medicineService.updateInventoryItem(
        inventoryId: inventoryId,
        discountPercent: discountPercent,
        status: status,
      );
      // Refresh inventory
      await fetchInventory(shopId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteInventoryItem({
    required String shopId,
    required String inventoryId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _medicineService.deleteInventoryItem(inventoryId);
      // Refresh inventory
      await fetchInventory(shopId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
