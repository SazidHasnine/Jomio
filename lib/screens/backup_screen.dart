import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final lastBackup = provider.lastBackupTime;

        return Scaffold(
          appBar: AppBar(
            title: const Text('ডাটা ব্যাকআপ (Cloud Backup)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFE53935),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_done,
                      color: Colors.green.shade700,
                      size: 72,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'আপনার ব্যবসায়িক ডাটা সুরক্ষিত রয়েছে',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'ফোন হারিয়ে বা নষ্ট হলেও আপনার কোনো লেনদেন হারাবে না। নতুন ফোনে লগিন করলেই সব ডাটা সাথে সাথে পেয়ে যাবেন।',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.sync, color: Colors.green),
                          ),
                          title: const Text('স্বয়ংক্রিয় ক্লাউড ব্যাকআপ', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Firebase ক্লাউড স্টোরেজে এনক্রিপ্ট করা'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('সক্রিয়', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('সর্বশেষ ব্যাকআপ সময়:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(
                              '${lastBackup.day}/${lastBackup.month}/${lastBackup.year} • ${lastBackup.hour}:${lastBackup.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('মোট সংরক্ষিত হিসাব:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(
                              '${provider.customers.length} জন কাস্টমার/সাপ্লায়ার',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: provider.isBackingUp ? null : () async {
                      await provider.triggerBackup();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ক্লাউডে ব্যাকআপ সফলভাবে সম্পন্ন হয়েছে!')),
                        );
                      }
                    },
                    icon: provider.isBackingUp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      provider.isBackingUp ? 'ডাটা ব্যাকআপ হচ্ছে...' : 'এখনই ব্যাকআপ নিন',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
