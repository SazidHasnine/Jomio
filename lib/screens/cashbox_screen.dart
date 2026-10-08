import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class CashboxScreen extends StatelessWidget {
  const CashboxScreen({super.key});

  void _showAddCashDialog(BuildContext context, bool isCashIn) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCashIn ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    isCashIn ? Icons.add_circle : Icons.remove_circle,
                    color: isCashIn ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isCashIn ? 'ক্যাশ ইন (টাকা জমা)' : 'ক্যাশ আউট (টাকা খরচ)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isCashIn ? Colors.green : Colors.red,
              ),
              decoration: InputDecoration(
                prefixText: '৳ ',
                labelText: 'টাকার পরিমাণ লিখুন',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: 'বিবরণ (ঐচ্ছিক)',
                hintText: isCashIn ? 'যেমন: নগদ বিক্রি, ব্যাংক উত্তোলন' : 'যেমন: দোকান ভাড়া, নাস্তা, পরিবহন',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (amount <= 0) return;
                  context.read<AppProvider>().addCashEntry(amount, isCashIn, descCtrl.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${isCashIn ? 'ক্যাশ ইন' : 'ক্যাশ আউট'} সফলভাবে যুক্ত হয়েছে!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCashIn ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('নিশ্চিত করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
            title: const Text('ক্যাশবক্স (Cashbox)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFE53935),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const Text('ক্যাশ ইন হ্যান্ড (বর্তমান ড্রয়ার ব্যালেন্স)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${provider.cashInHand.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('মোট জমা', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳ ${provider.totalCashIn.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('মোট খরচ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳ ${provider.totalCashOut.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddCashDialog(context, true),
                        icon: const Icon(Icons.add),
                        label: const Text('ক্যাশ ইন (+)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddCashDialog(context, false),
                        icon: const Icon(Icons.remove),
                        label: const Text('ক্যাশ আউট (-)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // History list title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('লেনদেনের বিবরণী', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('সর্বশেষ হিসাব', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: provider.cashEntries.isEmpty
                    ? const Center(
                        child: Text('এখনো কোনো ক্যাশ লেনদেন হয়নি।', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        itemCount: provider.cashEntries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = provider.cashEntries[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isCashIn ? Colors.green.shade50 : Colors.red.shade50,
                              child: Icon(
                                item.isCashIn ? Icons.arrow_downward : Icons.arrow_upward,
                                color: item.isCashIn ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(item.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${item.date.day}/${item.date.month}/${item.date.year} • ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${item.isCashIn ? '+' : '-'} ৳ ${item.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: item.isCashIn ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
