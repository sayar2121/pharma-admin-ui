import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../services/api_url.dart';
import '../../models/medicine_inventory.dart';

class MedicineInventoryScreen extends ConsumerStatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  ConsumerState<MedicineInventoryScreen> createState() => _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends ConsumerState<MedicineInventoryScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final shopId = ref.read(authProvider).user?.shopId;
      if (shopId != null) {
        ref.read(medicineProvider.notifier).fetchInventory(shopId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: SideNavBar(
        selectedIndex: 2, // Assuming index 2 is for Inventory
        onItemSelected: (index) {},
      ),
      appBar: CustomAppBar(
        title: 'My Inventory',
        subtitle: 'Manage your stock and prices',
        showDrawer: true,
        actions: [
          CustomAppBar.buildActionButton(
            icon: _isSearching ? Iconsax.close_square : Iconsax.search_normal,
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(medicineProvider.notifier).searchInventory('');
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
                  onChanged: (val) => ref.read(medicineProvider.notifier).searchInventory(val),
                  decoration: const InputDecoration(
                    hintText: 'Search in inventory...',
                    prefixIcon: Icon(Iconsax.search_normal, color: AppColors.primary),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          Expanded(
            child: state.isLoading && state.inventory.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)))
                    : state.filteredInventory.isEmpty
                        ? const Center(child: Text('Inventory is empty.'))
                        : RefreshIndicator(
                            onRefresh: () async {
                              final shopId = ref.read(authProvider).user?.shopId;
                              if (shopId != null) {
                                await ref.read(medicineProvider.notifier).fetchInventory(shopId);
                              }
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.screenPadding),
                              itemCount: state.filteredInventory.length,
                              itemBuilder: (context, index) {
                                final item = state.filteredInventory[index];
                                return _MedicineInventoryCard(item: item);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _MedicineInventoryCard extends StatelessWidget {
  final MedicineInventory item;

  const _MedicineInventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final medicine = item.medicine;
    if (medicine == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/medicine-details', extra: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppCardStyles.sleekCard,
        child: Row(
          children: [
            // Medicine Photo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: medicine.medicinePhoto != null
                    ? DecorationImage(
                        image: NetworkImage("${ApiUrl.baseUrl}/${medicine.medicinePhoto}"),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: medicine.medicinePhoto == null
                  ? const Icon(Iconsax.health, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          medicine.medicineName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == 'in stock' 
                              ? AppColors.success.withAlpha(20) 
                              : AppColors.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status == 'in stock' ? 'In Stock' : 'Out of Stock',
                          style: AppTextStyles.caption.copyWith(
                            color: item.status == 'in stock' ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(medicine.medicineCategory, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  
                  // Price Breakdown
                  Row(
                    children: [
                      Text(
                        '₹${item.displayPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${medicine.mrp}',
                        style: AppTextStyles.caption.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.discountPercent}% OFF',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
