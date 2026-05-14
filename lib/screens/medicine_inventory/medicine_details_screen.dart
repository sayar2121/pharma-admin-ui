import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../models/medicine_inventory.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../services/api_url.dart';

class MedicineDetailsScreen extends ConsumerStatefulWidget {
  final MedicineInventory inventoryItem;

  const MedicineDetailsScreen({super.key, required this.inventoryItem});

  @override
  ConsumerState<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends ConsumerState<MedicineDetailsScreen> {
  late TextEditingController _discountController;
  late String _stockStatus;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(text: widget.inventoryItem.discountPercent.toString());
    _stockStatus = widget.inventoryItem.status == 'in stock' ? 'In Stock' : 'Out of Stock';
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _updateInventory() async {
    final shopId = ref.read(authProvider).user?.shopId;
    if (shopId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(medicineProvider.notifier).updateInventoryItem(
        shopId: shopId,
        inventoryId: widget.inventoryItem.inventoryMedicineId ?? '',
        discountPercent: double.tryParse(_discountController.text),
        status: _stockStatus,
      );
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteInventory() async {
    final shopId = ref.read(authProvider).user?.shopId;
    if (shopId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to remove this item from your inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(medicineProvider.notifier).deleteInventoryItem(
          shopId: shopId,
          inventoryId: widget.inventoryItem.inventoryMedicineId ?? '',
        );
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed from inventory.')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicine = widget.inventoryItem.medicine;
    if (medicine == null) return const Scaffold(body: Center(child: Text('Medicine data missing')));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Medicine Details',
        subtitle: medicine.medicineName,
        showDrawer: false,
        showBackButton: true,
        actions: [
          CustomAppBar.buildActionButton(
            icon: _isEditing ? Iconsax.close_square : Iconsax.edit,
            onTap: () => setState(() => _isEditing = !_isEditing),
          ),
          CustomAppBar.buildActionButton(
            icon: Iconsax.trash,
            onTap: _deleteInventory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Medicine Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                      image: medicine.medicinePhoto != null
                          ? DecorationImage(
                              image: NetworkImage("${ApiUrl.baseUrl}/${medicine.medicinePhoto}"),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: medicine.medicinePhoto == null
                        ? const Icon(Iconsax.health, color: AppColors.primary, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(medicine.medicineName, style: AppTextStyles.header.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(medicine.medicineCategory, style: AppTextStyles.tagline),
                  const SizedBox(height: 16),
                  
                  // Inventory Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(
                        icon: Iconsax.box,
                        label: 'Stock Status',
                        value: _stockStatus,
                        color: _stockStatus == 'In Stock' ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Iconsax.discount_shape,
                        label: 'Discount',
                        value: '${_discountController.text}%',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing) ...[
                    Text('Edit Inventory Details', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount Percent (%)',
                        prefixIcon: Icon(Iconsax.discount_shape),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _stockStatus,
                      decoration: const InputDecoration(
                        labelText: 'Stock Status',
                        prefixIcon: Icon(Iconsax.box),
                      ),
                      items: ['In Stock', 'Out of Stock'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _stockStatus = val!),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateInventory,
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionTitle('Price Breakdown'),
                  _buildPriceInfo(medicine.mrp, double.tryParse(_discountController.text) ?? 0),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('General Information'),
                  _buildDetailItem(Iconsax.box, 'Quantity', medicine.medicineQuantity),
                  _buildDetailItem(Iconsax.health, 'Composition', medicine.medicineComposition ?? 'N/A'),
                  _buildDetailItem(Iconsax.note_text, 'Description', medicine.medicineDescription ?? 'No description available.'),
                  
                  if (medicine.precautions != null && medicine.precautions!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Precautions'),
                    ...medicine.precautions!.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppColors.error,).paddingOnly(top: 6, right: 8),
                          Expanded(child: Text(p, style: AppTextStyles.description)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.description.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(double mrp, double discount) {
    final finalPrice = mrp - (mrp * discount / 100);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        children: [
          _buildPriceRow('Maximum Retail Price (MRP)', '₹$mrp', isOld: true),
          const SizedBox(height: 8),
          _buildPriceRow('Discount ($discount%)', '- ₹${(mrp - finalPrice).toStringAsFixed(2)}', isDiscount: true),
          const Divider(height: 24),
          _buildPriceRow('Your Selling Price', '₹${finalPrice.toStringAsFixed(2)}', isBold: true, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isOld = false, bool isDiscount = false, bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.description.copyWith(fontSize: 14, color: isDiscount ? AppColors.success : AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isDiscount ? AppColors.success : AppColors.textPrimary),
            decoration: isOld ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary).paddingOnly(top: 2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget paddingOnly({double top = 0, double right = 0}) => Padding(padding: EdgeInsets.only(top: top, right: right), child: this);
}
