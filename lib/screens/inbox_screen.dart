import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'সুপার QR পেমেন্ট সুবিধা চালু হয়েছে!',
        'body': 'এখন আপনার দোকানের যেকোনো কাস্টমার বিকাশ, নগদ ও ব্যাংকের অ্যাপ থেকে সরাসরি কিউআর স্ক্যান করে পেমেন্ট করতে পারবে।',
        'time': 'আজ সকাল ১০:৩০',
        'icon': Icons.qr_code_2,
        'color': Colors.red,
      },
      {
        'title': 'দৈনিক ক্যাশবক্স মিলিয়ে নিন',
        'body': 'দিনের শেষ বেচাকেনা ও দোকান খরচের হিসাব ক্যাশবক্সে লিখে ব্যালেন্স নির্ভুল রাখুন।',
        'time': 'গতকাল সন্ধ্যা ৭:১৫',
        'icon': Icons.point_of_sale,
        'color': Colors.green,
      },
      {
        'title': 'বকেয়া তাগাদা মেসেজ পাঠানো শুরু করুন',
        'body': 'যেসব কাস্টমারের বকেয়া রয়েছে তাদের গ্রুপ তাগাদা ফিচার ব্যবহার করে ফ্রি এসএমএস পাঠান।',
        'time': '৩ দিন আগে',
        'icon': Icons.sms,
        'color': Colors.blue,
      },
      {
        'title': 'জমিও বিজনেস লেজারে স্বাগতম!',
        'body': 'আপনার ব্যবসার সকল খাতা ও বাকি-নগদ হিসাব ডিজিটাল করুন সহজে এবং নিশ্চিন্তে।',
        'time': '৫ দিন আগে',
        'icon': Icons.verified,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ইনবক্স (Inbox)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: (item['color'] as Color).withOpacity(0.12),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['body'] as String,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['time'] as String,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
