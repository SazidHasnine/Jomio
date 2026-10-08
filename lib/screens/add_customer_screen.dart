import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../providers/app_provider.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  UserType _userType = UserType.customer;
  bool isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে নাম লিখুন')));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে মোবাইল নম্বর লিখুন')));
      return;
    }

    setState(() => isLoading = true);
    
    final provider = context.read<AppProvider>();
    final customer = Customer(
      id: '', // Firestore generates this
      name: name,
      phone: phone,
      balance: 0,
      userType: _userType,
      lastTransactionDate: DateTime.now(),
    );

    final db = FirestoreDatabaseService();
    if (provider.currentUserId != null) {
      await db.addCustomer(provider.currentUserId!, customer);
      await provider.loadCustomers(); // refresh list
    }
    
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_userType == UserType.customer ? "কাস্টমার" : "সাপ্লায়ার"} সফলভাবে যুক্ত হয়েছে!')),
      );
      Navigator.pop(context);
    }
  }

  void _importFromPhonebook() {
    // Simulated phonebook contacts selector
    final dummyContacts = [
      {'name': 'মো: কামাল হোসেন', 'phone': '01711223344'},
      {'name': 'রফিকুল ইসলাম', 'phone': '01819556677'},
      {'name': 'হাসান মাহমুদ', 'phone': '01912334455'},
      {'name': 'মেসার্স ভাই ভাই ট্রেডার্স', 'phone': '01611778899'},
      {'name': 'আব্দুল করিম', 'phone': '01552345678'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.perm_contact_calendar_outlined, color: Color(0xFFE53935)),
                SizedBox(width: 10),
                Text('ফোনবুক থেকে যোগাযোগ নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: dummyContacts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final c = dummyContacts[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(c['name']![0]),
                    ),
                    title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c['phone']!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      setState(() {
                        _nameCtrl.text = c['name']!;
                        _phoneCtrl.text = c['phone']!;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${c['name']} নির্বাচন করা হয়েছে')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = _userType == UserType.customer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন কাস্টমার / সাপ্লায়ার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Avatar & Customer/Supplier Selector Row (matching TallyKhata)
            Row(
              children: [
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('প্রোফাইল ছবি ক্যামেরা/গ্যালারি থেকে নির্বাচন করুন')),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 36, color: Colors.grey),
                      ),
                      Container(
                        height: 22,
                        width: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE53935),
                        ),
                        child: const Center(
                          child: Icon(Icons.camera_alt, size: 13, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Segmented Radios
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _userType = UserType.customer),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCustomer ? const Color(0xFFE53935).withOpacity(0.08) : Colors.transparent,
                        border: Border.all(
                          color: isCustomer ? const Color(0xFFE53935) : Colors.grey.shade300,
                          width: isCustomer ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Radio<UserType>(
                            value: UserType.customer,
                            groupValue: _userType,
                            activeColor: const Color(0xFFE53935),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              if (val != null) setState(() => _userType = val);
                            },
                          ),
                          const Text('কাস্টমার', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _userType = UserType.supplier),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: !isCustomer ? const Color(0xFFE53935).withOpacity(0.08) : Colors.transparent,
                        border: Border.all(
                          color: !isCustomer ? const Color(0xFFE53935) : Colors.grey.shade300,
                          width: !isCustomer ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Radio<UserType>(
                            value: UserType.supplier,
                            groupValue: _userType,
                            activeColor: const Color(0xFFE53935),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              if (val != null) setState(() => _userType = val);
                            },
                          ),
                          const Text('সাপ্লায়ার', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Import from Phonebook Button
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onPressed: _importFromPhonebook,
                icon: const Icon(Icons.perm_contact_calendar_outlined, size: 20),
                label: const Text('ফোনবুক থেকে যোগ করি', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),

            // Input Fields
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                labelText: 'নাম',
                hintText: isCustomer ? 'কাস্টমারের নাম লিখুন' : 'সাপ্লায়ারের নাম লিখুন',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_outlined),
                labelText: 'মোবাইল নম্বর',
                hintText: '০১৭xxxxxxxx',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('নিশ্চিত করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
