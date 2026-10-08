import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../models/customer.dart';

class TallyMessageScreen extends StatefulWidget {
  const TallyMessageScreen({super.key});

  @override
  State<TallyMessageScreen> createState() => _TallyMessageScreenState();
}

class _TallyMessageScreenState extends State<TallyMessageScreen> {
  Customer? _selectedCustomer;
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messageCtrl.text = 'সম্মানিত গ্রাহক, আপনার আজকের লেনদেন ও বর্তমান খাতার ব্যালেন্সের তথ্য দেওয়া হলো। জমিও বিজনেস লেজার ব্যবহার করার জন্য ধন্যবাদ।';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _onCustomerSelected(Customer c) {
    setState(() {
      _selectedCustomer = c;
      _phoneCtrl.text = c.phone;
      final balanceStatus = c.balance > 0 ? 'জমা (অ্যাডভান্স) ৳${c.balance}' : (c.balance < 0 ? 'বকেয়া ৳${c.balance.abs()}' : 'পরিশোধ ৳০');
      _messageCtrl.text = 'সম্মানিত ${c.name}, আপনার বর্তমান খাতার স্থিতি: $balanceStatus। নিয়মিত লেনদেনের জন্য আপনাকে ধন্যবাদ। - ${context.read<AppProvider>().businessName}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('টালি-মেসেজ (SMS Receipt)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sms, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('বিনামূল্যে এসএমএস / মেসেজ শেয়ার', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          'গ্রাহককে তার বর্তমান ব্যালেন্স, ভাউচার রশিদ অথবা শুভেচ্ছা বার্তা সরাসরি এসএমএস বা হোয়াটসঅ্যাপে পাঠান।',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Customer Dropdown / Selector
            const Text('কাস্টমার নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  isExpanded: true,
                  hint: const Text('তালিকা থেকে কাস্টমার বেছে নিন'),
                  value: _selectedCustomer,
                  items: provider.customers.map((c) {
                    return DropdownMenuItem<Customer>(
                      value: c,
                      child: Text('${c.name} (${c.phone})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _onCustomerSelected(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recipient Phone Number
            const Text('মোবাইল নম্বর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                hintText: '০১৭xxxxxxxx',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            // Message Body
            const Text('মেসেজের বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'মেসেজ লিখুন...',
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _messageCtrl.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('মেসেজ টেক্সট কপি হয়েছে!')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('কপি করুন'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_phoneCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('মোবাইল নম্বর দিন')),
                        );
                        return;
                      }
                      final uri = Uri(
                        scheme: 'sms',
                        path: _phoneCtrl.text.trim(),
                        queryParameters: {'body': _messageCtrl.text.trim()},
                      );
                      try {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          Clipboard.setData(ClipboardData(text: _messageCtrl.text));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('মেসেজ টেক্সট ক্লিপবোর্ডে কপি করা হয়েছে!')),
                            );
                          }
                        }
                      } catch (_) {
                        Clipboard.setData(ClipboardData(text: _messageCtrl.text));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('মেসেজ টেক্সট ক্লিপবোর্ডে কপি করা হয়েছে!')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('মেসেজ পাঠান'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}
