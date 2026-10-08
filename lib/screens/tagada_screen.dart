import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../models/customer.dart';

class TagadaScreen extends StatefulWidget {
  const TagadaScreen({super.key});

  @override
  State<TagadaScreen> createState() => _TagadaScreenState();
}

class _TagadaScreenState extends State<TagadaScreen> {
  final Set<String> _selectedCustomerIds = {};

  Future<void> _sendSms(String phone, String body) async {
    final uri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': body});
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Clipboard.setData(ClipboardData(text: body));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বার্তা ক্লিপবোর্ডে কপি করা হয়েছে')));
        }
      }
    } catch (_) {
      Clipboard.setData(ClipboardData(text: body));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বার্তা ক্লিপবোর্ডে কপি করা হয়েছে')));
      }
    }
  }

  void _sendReminder(BuildContext context, Customer customer) {
    final businessName = context.read<AppProvider>().businessName;
    final message = 'সম্মানিত ${customer.name}, আপনার নিকট $businessName-এর বকেয়া পাওনা ৳${customer.balance.abs().toStringAsFixed(0)}। অনুগ্রহ করে বকেয়া পরিশোধ করে সহযোগিতা করুন। ধন্যবাদ।';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.notifications_active, color: Color(0xFFE53935)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('বকেয়া: ৳${customer.balance.abs().toStringAsFixed(0)} • মোবাইল: ${customer.phone}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('তাগাদা বার্তার খসড়া:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(message, style: const TextStyle(fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('তাগাদা মেসেজ ক্লিপবোর্ডে কপি হয়েছে!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('কপি করুন'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _sendSms(customer.phone, message);
                    },
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('SMS পাঠান'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // Customers with pending dues (balance < 0 means due)
    final dueCustomers = provider.customers.where((c) => c.balance < 0).toList();
    final totalDueAmount = dueCustomers.fold(0.0, (sum, c) => sum + c.balance.abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('গ্রুপ তাগাদা (Payment Reminder)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Due Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const Text('মোট বকেয়া পাওনা তাগাদার জন্য', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '৳ ${totalDueAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  '${dueCustomers.length} জন কাস্টমারের কাছে পাওনা রয়েছে',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'বকেয়া কাস্টমার তালিকা (${dueCustomers.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (dueCustomers.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_selectedCustomerIds.length == dueCustomers.length) {
                          _selectedCustomerIds.clear();
                        } else {
                          _selectedCustomerIds.addAll(dueCustomers.map((c) => c.id));
                        }
                      });
                    },
                    icon: Icon(_selectedCustomerIds.length == dueCustomers.length ? Icons.deselect : Icons.select_all, size: 18),
                    label: Text(_selectedCustomerIds.length == dueCustomers.length ? 'সব বাদ' : 'সব নির্বাচন'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)),
                  ),
              ],
            ),
          ),

          Expanded(
            child: dueCustomers.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                          SizedBox(height: 12),
                          Text(
                            'কোনো কাস্টমারের বকেয়া নেই!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'সব কাস্টমারের হিসাব পরিশোধ রয়েছে। নতুন বকেয়া যুক্ত হলে এখানে তাগাদা পাঠাতে পারবেন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dueCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = dueCustomers[index];
                      final isSelected = _selectedCustomerIds.contains(customer.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Text(
                              customer.name.isNotEmpty ? customer.name[0] : '?',
                              style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('মোবাইল: ${customer.phone}\nবকেয়া: ৳${customer.balance.abs().toStringAsFixed(0)}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filledTonal(
                                onPressed: () => _sendReminder(context, customer),
                                icon: const Icon(Icons.notifications_active, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: const Color(0xFFE53935),
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                activeColor: const Color(0xFFE53935),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedCustomerIds.add(customer.id);
                                    } else {
                                      _selectedCustomerIds.remove(customer.id);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (dueCustomers.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final count = _selectedCustomerIds.isEmpty ? dueCustomers.length : _selectedCustomerIds.length;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$count জন কাস্টমারকে গ্রুপ তাগাদা পাঠানো শুরু হয়েছে!')),
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: Text(
                      _selectedCustomerIds.isEmpty
                          ? 'সবাইকে (${dueCustomers.length} জন) গ্রুপ তাগাদা পাঠান'
                          : 'নির্বাচিত (${_selectedCustomerIds.length} জন) তাগাদা পাঠান',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
