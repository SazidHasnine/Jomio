import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class MultiBusinessScreen extends StatelessWidget {
  const MultiBusinessScreen({super.key});

  void _showAddBusinessDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
            const Row(
              children: [
                Icon(Icons.store, color: Color(0xFFE53935)),
                SizedBox(width: 10),
                Text('নতুন ব্যবসা প্রতিষ্ঠান যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'দোকান / ব্যবসার নাম',
                hintText: 'যেমন: মেসার্স জমিও ফার্মেসি',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeCtrl,
              decoration: InputDecoration(
                labelText: 'ব্যবসার ধরন',
                hintText: 'যেমন: মুদি, ফার্মেসি, পাইকারি',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ব্যবসায়িক ফোন নম্বর',
                hintText: '+880 1xxxxxxxxx',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  context.read<AppProvider>().addBusiness(
                    name,
                    typeCtrl.text.trim().isEmpty ? 'জেনারেল স্টোর' : typeCtrl.text.trim(),
                    phoneCtrl.text.trim().isEmpty ? '+880 1700 000000' : phoneCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name সফলভাবে যোগ করা হয়েছে!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('সংরক্ষণ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            title: const Text('মাল্টি ব্যবসা (Multi-Business)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFE53935),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront, color: Colors.green, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('একাধিক ব্যবসা এক অ্যাপেই পরিচালনা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            'প্রতিটি ব্যবসার জন্য আলাদা আলাদা খাতা, হিসাব ও কাস্টমার তালিকা সুরক্ষিত থাকবে।',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('আপনার ব্যবসা সমূহের তালিকা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ...provider.businesses.map((b) {
                final isSelected = b.isSelected;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFE53935) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? const Color(0xFFE53935) : Colors.grey.shade200,
                      child: Icon(Icons.store, color: isSelected ? Colors.white : Colors.black54),
                    ),
                    title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${b.type} • ${b.phone}'),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('চলতি ব্যবসা', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        : TextButton(
                            onPressed: () {
                              provider.switchBusiness(b.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${b.name}-এ পরিবর্তন করা হয়েছে!')),
                              );
                            },
                            child: const Text('সুইচ করুন'),
                          ),
                  ),
                );
              }),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddBusinessDialog(context),
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_business),
            label: const Text('নতুন ব্যবসা যোগ'),
          ),
        );
      },
    );
  }
}
