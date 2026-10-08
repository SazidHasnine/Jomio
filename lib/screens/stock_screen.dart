import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final buyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    String unit = 'টি';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2, color: Color(0xFFE53935)),
                  SizedBox(width: 10),
                  Text('নতুন পণ্য যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'পণ্যের নাম',
                  hintText: 'যেমন: মিনিকেট চাল, সয়াবিন তেল',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'পরিমাণ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      decoration: InputDecoration(
                        labelText: 'একক',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'টি', child: Text('টি')),
                        DropdownMenuItem(value: 'কেজি', child: Text('কেজি')),
                        DropdownMenuItem(value: 'লিটার', child: Text('লিটার')),
                        DropdownMenuItem(value: 'বস্তা', child: Text('বস্তা')),
                        DropdownMenuItem(value: 'প্যাকেট', child: Text('প্যাকেট')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => unit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: buyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        labelText: 'ক্রয় মূল্য (প্রতি একক)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: sellCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        labelText: 'বিক্রয় মূল্য (প্রতি একক)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                    final buy = double.tryParse(buyCtrl.text.trim()) ?? 0;
                    final sell = double.tryParse(sellCtrl.text.trim()) ?? 0;
                    if (name.isEmpty) return;

                    context.read<AppProvider>().addStockItem(name, qty, buy, sell, unit);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name সফলভাবে স্টকে যুক্ত হয়েছে!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('পণ্য সংরক্ষণ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('স্টক হিসাব (Stock)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFE53935),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('মোট স্টক মূল্য', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '৳ ${provider.totalStockValuation.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('পণ্য সংখ্যা', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.stockItems.length} টি আইটেম',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Items Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('পণ্যের তালিকা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showAddProductDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('নতুন পণ্য'),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)),
                    ),
                  ],
                ),
              ),

              // Product List
              Expanded(
                child: provider.stockItems.isEmpty
                    ? const Center(
                        child: Text('কোনো পণ্য যুক্ত করা হয়নি।', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.stockItems.length,
                        itemBuilder: (context, index) {
                          final item = provider.stockItems[index];
                          final isLowStock = item.quantity <= 5;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isLowStock ? Colors.orange.shade50 : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.inventory_2,
                                          color: isLowStock ? Colors.orange.shade800 : Colors.blue.shade700,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ক্রয়: ৳${item.buyPrice} | বিক্রয়: ৳${item.sellPrice} / ${item.unit}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isLowStock)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'স্টক কম',
                                            style: TextStyle(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('বর্তমান স্টক', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                          Text(
                                            '${item.quantity} ${item.unit}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isLowStock ? Colors.red : Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton.filledTonal(
                                            onPressed: () {
                                              provider.updateStockQuantity(item.id, -1);
                                            },
                                            icon: const Icon(Icons.remove, size: 18),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.red.shade50,
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton.filledTonal(
                                            onPressed: () {
                                              provider.updateStockQuantity(item.id, 1);
                                            },
                                            icon: const Icon(Icons.add, size: 18),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.green.shade50,
                                              foregroundColor: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddProductDialog(context),
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('পণ্য যোগ'),
          ),
        );
      },
    );
  }
}
