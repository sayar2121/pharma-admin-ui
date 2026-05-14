import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/medicine_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../cards/available_medicine/available_medicine_card.dart';
import '../../cards/available_medicine/available_medicine_bottomsheet.dart';

class AvailableMedicineScreen extends ConsumerStatefulWidget {
  const AvailableMedicineScreen({super.key});

  @override
  ConsumerState<AvailableMedicineScreen> createState() => _AvailableMedicineScreenState();
}

class _AvailableMedicineScreenState extends ConsumerState<AvailableMedicineScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial list of medicines
    Future.microtask(() => ref.read(medicineProvider.notifier).fetchMedicines());
    
    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(medicineProvider.notifier).loadMoreMedicines();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(medicineProvider.notifier).fetchMedicines(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    final medicineState = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: SideNavBar(
        selectedIndex: 1,
        onItemSelected: (index) {
          // Nav handling is inside SideNavBar
        },
      ),
      appBar: CustomAppBar(
        title: 'Available Medicine',
        subtitle: 'Manage your medicine catalog',
        showDrawer: true,
        actions: [
          CustomAppBar.buildActionButton(
            icon: _isSearching ? Iconsax.close_square : Iconsax.search_normal,
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(medicineProvider.notifier).fetchMedicines();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
              child: Container(
                decoration: AppCardStyles.sleekCard.copyWith(borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search medicines by name...',
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
          Expanded(
            child: medicineState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : medicineState.error != null
                    ? Center(
                        child: Text(
                          medicineState.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    : medicineState.medicines.isEmpty
                        ? const Center(child: Text('No medicines found.'))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppSpacing.screenPadding),
                            itemCount: medicineState.medicines.length + (medicineState.isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == medicineState.medicines.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              
                              final medicine = medicineState.medicines[index];
                              return AvailableMedicineCard(
                                medicine: medicine,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => AvailableMedicineBottomSheet(medicine: medicine),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
