import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../providers/app_provider.dart';
import 'transaction_entry_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _db = FirestoreDatabaseService();
  List<AppTransaction> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await _db.getTransactions(widget.customer.id);
    if (mounted) {
      setState(() {
        transactions = data;
        isLoading = false;
      });
    }
  }

  void _addTransaction(bool isGot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionEntryScreen(
          customer: widget.customer,
          isGot: isGot,
        ),
      ),
    );
    if (result == true) {
      setState(() => isLoading = true);
      await _loadTransactions();
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$phone নম্বরে কল ডায়াল করা হচ্ছে')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('কল করতে ব্যর্থ হয়েছে: $phone')));
      }
    }
  }

  Future<void> _sendSms(String phone, String body) async {
    final uri = Uri(scheme: 'sms', path: phone, queryParameters: {'body': body});
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Clipboard.setData(ClipboardData(text: body));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মেসেজ টেক্সট ক্লিপবোর্ডে কপি করা হয়েছে')));
        }
      }
    } catch (_) {
      Clipboard.setData(ClipboardData(text: body));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মেসেজ টেক্সট ক্লিপবোর্ডে কপি করা হয়েছে')));
      }
    }
  }

  void _sendTagadaReminder() {
    final businessName = context.read<AppProvider>().businessName;
    final message = 'সম্মানিত ${widget.customer.name}, আপনার নিকট $businessName-এর বকেয়া পাওনা ৳${widget.customer.balance.abs().toStringAsFixed(0)}। অনুগ্রহ করে বকেয়া পরিশোধ করে সহযোগিতা করুন।';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Color(0xFFE53935)),
                SizedBox(width: 10),
                Text('তাগাদা বার্তা পাঠান', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(message, style: const TextStyle(fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('বার্তা কপি করা হয়েছে!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('কপি করুন'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _sendSms(widget.customer.phone, message);
                    },
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('SMS পাঠান'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
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
    final balance = widget.customer.balance;
    final isDue = balance < 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customer.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.customer.phone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            tooltip: 'কল করুন',
            onPressed: () => _makePhoneCall(widget.customer.phone),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            tooltip: 'তাগাদা পাঠান',
            onPressed: _sendTagadaReminder,
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Summary Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: const Color(0xFFE53935),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDue ? 'মোট বাকি (পাবো)' : (balance > 0 ? 'মোট অগ্রিম (দেবো)' : 'হিসাব পরিশোধ'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDue ? Colors.red.shade700 : (balance > 0 ? Colors.green.shade700 : Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳ ${balance.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDue ? Colors.red.shade700 : (balance > 0 ? Colors.green.shade700 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _sendTagadaReminder,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('তাগাদা দিন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('লেনদেনের খতিয়ান', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('তারিখ ও বিবরণ', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text('এখনো কোনো লেনদেন যুক্ত করা হয়নি।', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            const Text('নিচের বাটন দিয়ে নতুন লেনদেন যুক্ত করুন।', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isGot = tx.amountGot > 0;
                          final amount = isGot ? tx.amountGot : tx.amountGave;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isGot ? Colors.green.shade50 : Colors.red.shade50,
                              child: Icon(
                                isGot ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isGot ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              isGot ? 'পেলাম (জমা)' : 'দিলাম (বাকি/বেচা)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tx.note.isNotEmpty)
                                  Text(tx.note, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                                Text(
                                  '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isGot ? '+' : '-'} ৳ ${amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isGot ? Colors.green : Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (tx.photoUrl != null)
                                  const Icon(Icons.receipt, size: 14, color: Colors.grey),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTransaction(false), // Gave
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('দিলাম ৳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTransaction(true), // Got
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('পেলাম ৳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
