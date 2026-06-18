import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';
import '../models/order.dart';

class BillGenerationDialog extends StatefulWidget {
  final Function(List<Map<String, dynamic>> items, double itemTotal) onSubmit;
  final VoidCallback onCancel;
  final Order? order;

  const BillGenerationDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.order,
  });

  @override
  State<BillGenerationDialog> createState() => _BillGenerationDialogState();
}

class _BillGenerationDialogState extends State<BillGenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Store controllers and flags for each row
  final List<Map<String, dynamic>> _controllers = [];

  void _addItem({String name = '', String quantity = '1', String price = '', bool isRequested = false}) {
    final nameCtrl = TextEditingController(text: name);
    final qtyCtrl = TextEditingController(text: quantity);
    final priceCtrl = TextEditingController(text: price);
    final subNameCtrl = TextEditingController();

    void updateState() {
      setState(() {});
    }

    qtyCtrl.addListener(updateState);
    priceCtrl.addListener(updateState);
    subNameCtrl.addListener(updateState);

    setState(() {
      _controllers.add({
        'originalName': name,
        'name': nameCtrl,
        'subName': subNameCtrl,
        'quantity': qtyCtrl,
        'price': priceCtrl,
        'isRequested': isRequested,
        'status': 'yes', // 'yes', 'no', 'substitute'
      });
    });
  }

  void _removeItem(int index) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        final removed = _controllers.removeAt(index);
        removed['name']?.dispose();
        removed['subName']?.dispose();
        removed['quantity']?.dispose();
        removed['price']?.dispose();
      });
    });
  }

  double get _itemTotal {
    return _controllers.fold(0.0, (sum, ctrl) {
      if (ctrl['isRequested'] == true && ctrl['status'] == 'no') return sum;
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
      final List<Map<String, dynamic>> processedItems = [];
      for (var ctrl in _controllers) {
        if (ctrl['isRequested'] == true && ctrl['status'] == 'no') continue;
        
        final isSub = ctrl['isRequested'] == true && ctrl['status'] == 'substitute';
        final name = isSub ? ctrl['subName']!.text.trim() : ctrl['name']!.text.trim();
        final qty = int.tryParse(ctrl['quantity']!.text) ?? 1;
        final price = double.tryParse(ctrl['price']!.text) ?? 0.0;
        
        processedItems.add({
          'name': name,
          'quantity': qty,
          'price': price,
          'total_price': qty * price,
        });
      }

      if (processedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All items are unavailable. Please reject the order instead.')),
        );
        return;
      }

      // Unfocus before destroying the dialog to prevent web FocusManager crashes
      FocusScope.of(context).unfocus();

      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          widget.onSubmit(processedItems, _itemTotal);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.order != null && widget.order!.type != 'prescription' && widget.order!.items.isNotEmpty) {
      for (var item in widget.order!.items) {
        _addItem(
          name: item.name,
          quantity: item.quantity.toString(),
          price: (item.totalPrice / item.quantity).toStringAsFixed(2),
          isRequested: true,
        );
      }
    } else {
      _addItem(); // Add one empty row by default
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl['name']?.dispose();
      ctrl['subName']?.dispose();
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
                          Future.delayed(const Duration(milliseconds: 50), () {
                            if (mounted) widget.onCancel();
                          });
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
    final bool isRequested = ctrls['isRequested'] == true;
    final String status = ctrls['status'] ?? 'yes';
    final bool isSub = status == 'substitute';
    final bool isNo = status == 'no';
    
    Widget buildChip(String label, String value) {
      return ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: status == value ? Colors.white : AppColors.textPrimary)),
        selected: status == value,
        selectedColor: AppColors.primary,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              ctrls['status'] = value;
              // If switched back to yes, clear substitute name
              if (value == 'yes') ctrls['subName']?.clear();
            });
          }
        },
      );
    }

    return Container(
      key: ObjectKey(ctrls),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNo ? AppColors.divider.withAlpha(20) : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRequested) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      buildChip('Yes', 'yes'),
                      buildChip('Substitute', 'substitute'),
                      buildChip('No', 'no'),
                    ],
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
          ] else if (_controllers.length > 1) ...[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error),
                onPressed: () => _removeItem(index),
              ),
            ),
          ],
          
          if (isRequested)
            Text(
              'Requested: ${ctrls['originalName']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isNo ? AppColors.textSecondary : AppColors.textPrimary,
                decoration: isNo ? TextDecoration.lineThrough : null,
              ),
            ),
            
          if (isNo) ...[
            const SizedBox(height: 8),
            const Text('Marked as unavailable', style: TextStyle(color: AppColors.error, fontStyle: FontStyle.italic)),
          ] else ...[
            const SizedBox(height: 12),
            if (!isRequested || isSub) ...[
              TextFormField(
                controller: isSub ? ctrls['subName'] : ctrls['name'],
                decoration: InputDecoration(
                  labelText: isSub ? 'Substitute Medicine Name' : 'Medicine Name',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
            ],
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
                    readOnly: isRequested && !isSub,
                    decoration: InputDecoration(
                      labelText: 'Unit Price (₹)',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      fillColor: isRequested && !isSub ? AppColors.divider.withAlpha(50) : null,
                      filled: isRequested && !isSub,
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
        ],
      ),
    );
  }
}
