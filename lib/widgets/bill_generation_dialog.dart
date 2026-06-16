import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_theme.dart';

class BillGenerationDialog extends StatefulWidget {
  final Function(List<Map<String, dynamic>> items, double itemTotal) onSubmit;
  final VoidCallback onCancel;

  const BillGenerationDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<BillGenerationDialog> createState() => _BillGenerationDialogState();
}

class _BillGenerationDialogState extends State<BillGenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Store controllers for each row
  final List<Map<String, TextEditingController>> _controllers = [];

  void _addItem() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    void updateState() {
      setState(() {});
    }

    qtyCtrl.addListener(updateState);
    priceCtrl.addListener(updateState);

    setState(() {
      _controllers.add({
        'name': nameCtrl,
        'quantity': qtyCtrl,
        'price': priceCtrl,
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      final removed = _controllers.removeAt(index);
      removed['name']?.dispose();
      removed['quantity']?.dispose();
      removed['price']?.dispose();
    });
  }

  double get _itemTotal {
    return _controllers.fold(0.0, (sum, ctrl) {
      final qty = int.tryParse(ctrl['quantity']!.text) ?? 1;
      final price = double.tryParse(ctrl['price']!.text) ?? 0.0;
      return sum + (qty * price);
    });
  }

  void _submit() {
    if (_controllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Calculate total price per item
      final processedItems = _controllers.map((ctrl) {
        final name = ctrl['name']!.text.trim();
        final qty = int.tryParse(ctrl['quantity']!.text) ?? 1;
        final price = double.tryParse(ctrl['price']!.text) ?? 0.0;
        return {
          'name': name,
          'quantity': qty,
          'price': price,
          'total_price': qty * price,
        };
      }).toList();

      // Unfocus before destroying the dialog to prevent web FocusManager crashes
      FocusScope.of(context).unfocus();

      widget.onSubmit(processedItems, _itemTotal);
    }
  }

  @override
  void initState() {
    super.initState();
    _addItem(); // Add one empty row by default
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl['name']?.dispose();
      ctrl['quantity']?.dispose();
      ctrl['price']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: AppCardStyles.sleekCard.copyWith(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(color: AppColors.primary),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.receipt_add, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Generate Bill',
                          style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          widget.onCancel();
                        },
                      ),
                    ],
                  ),
                ),

                // Form
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Medicines from Prescription',
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(_controllers.length, (index) {
                            return _buildItemRow(index);
                          }),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Iconsax.add_circle, size: 18),
                            label: const Text('Add Another Medicine'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Total & Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.divider.withAlpha(128)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Item Total:',
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                          ),
                          Text(
                            '₹${_itemTotal.toStringAsFixed(2)}',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit Bill & Accept Order',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(int index) {
    final ctrls = _controllers[index];
    return Container(
      key: ObjectKey(ctrls), // Use controller map as key to retain state across list changes
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: ctrls['name'],
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
              ),
              if (_controllers.length > 1)
                IconButton(
                  icon: const Icon(Iconsax.trash, color: AppColors.error),
                  onPressed: () => _removeItem(index),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: ctrls['quantity'],
                  decoration: const InputDecoration(
                    labelText: 'Qty',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Req';
                    if (int.tryParse(value.trim()) == null) return 'Inv';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: ctrls['price'],
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (₹)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Req';
                    if (double.tryParse(value.trim()) == null) return 'Inv';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
