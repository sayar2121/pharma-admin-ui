import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../models/available_medicine.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/auth_provider.dart'; // To get shopId
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../services/api_url.dart';

class AddToInventoryScreen extends ConsumerStatefulWidget {
  final AvailableMedicine medicine;

  const AddToInventoryScreen({super.key, required this.medicine});

  @override
  ConsumerState<AddToInventoryScreen> createState() => _AddToInventoryScreenState();
}

class _AddToInventoryScreenState extends ConsumerState<AddToInventoryScreen> {
  final _discountController = TextEditingController(text: '0');
  String _stockStatus = 'In Stock';
  bool _isLoading = false;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _addToInventory() async {
    final shopId = ref.read(authProvider).user?.shopId;
    if (shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop ID not found. Please login again.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(medicineProvider.notifier).addToInventory(
        shopId: shopId,
        medicineId: widget.medicine.medicineId ?? '',
        discountPercent: double.tryParse(_discountController.text) ?? 0,
        status: _stockStatus,
      );
      if (mounted) {
        context.pop(); // Go back to bottom sheet
        context.pop(); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Inventory successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Add to Inventory',
        subtitle: 'Set your stock and discount',
        showDrawer: false,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Medicine Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppCardStyles.sleekCard,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: widget.medicine.medicinePhoto != null
                          ? DecorationImage(
                              image: NetworkImage("${ApiUrl.baseUrl}/${widget.medicine.medicinePhoto}"),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.medicine.medicinePhoto == null
                        ? const Icon(Iconsax.health, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.medicine.medicineName, style: AppTextStyles.cardTitle),
                        const SizedBox(height: 4),
                        Text(widget.medicine.medicineCategory, style: AppTextStyles.caption),
                        const SizedBox(height: 8),
                        Text('MRP: ₹${widget.medicine.mrp}', style: AppTextStyles.description.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            Text('Discount Percentage (%)', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter discount (e.g. 10)',
                prefixIcon: Icon(Iconsax.discount_shape, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),

            Text('Stock Status', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: AppCardStyles.sleekCard,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _stockStatus,
                  isExpanded: true,
                  onChanged: (value) => setState(() => _stockStatus = value!),
                  items: ['In Stock', 'Out of Stock'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: AppTextStyles.description),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addToInventory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm & Add to Inventory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
