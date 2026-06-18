import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order.dart';
import '../../../theme/app_theme.dart';

class GenerateQuoteDialog extends ConsumerStatefulWidget {
  final Order order;
  final Function(List<Map<String, dynamic>> items, double itemTotal) onSubmit;

  const GenerateQuoteDialog({super.key, required this.order, required this.onSubmit});

  @override
  ConsumerState<GenerateQuoteDialog> createState() => _GenerateQuoteDialogState();
}

class _GenerateQuoteDialogState extends ConsumerState<GenerateQuoteDialog> {
  final List<Map<String, dynamic>> _items = [];
  
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  double get _itemTotal {
    double total = 0;
    for (var item in _items) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty || 
        _qtyController.text.trim().isEmpty || 
        _priceController.text.trim().isEmpty) {
      return;
    }

    final int qty = int.tryParse(_qtyController.text) ?? 1;
    final double price = double.tryParse(_priceController.text) ?? 0.0;

    setState(() {
      _items.add({
        "name": _nameController.text.trim(),
        "quantity": qty,
        "price": price,
      });
    });

    _nameController.clear();
    _qtyController.clear();
    _priceController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generate Customer Bill',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Itemize the medicines based on the prescription to send a quote to the customer.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Add Item Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Qty',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price/Unit (₹)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addItem,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Icon(Icons.add),
                      )
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Added Items List
            if (_items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No items added yet', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (context, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final itemTotal = item['price'] * item['quantity'];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item['quantity']} x ₹${item['price']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹$itemTotal', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _removeItem(index),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Item Subtotal:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('₹$_itemTotal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _items.isEmpty ? null : () {
                  FocusScope.of(context).unfocus();
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (mounted) {
                      widget.onSubmit(_items, _itemTotal);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Bill to Customer', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
