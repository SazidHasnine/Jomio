import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BusinessNotesScreen extends StatelessWidget {
  const BusinessNotesScreen({super.key});

  void _showAddNoteDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

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
                Icon(Icons.note_alt, color: Color(0xFFE53935)),
                SizedBox(width: 10),
                Text('নতুন ব্যবসার নোট লিখুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'নোটের শিরোনাম',
                hintText: 'যেমন: চালের অর্ডার, দোকান ভাড়ার তারিখ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'বিস্তারিত বিবরণ',
                hintText: 'প্রয়োজনীয় তথ্য বিস্তারিত লিখে রাখুন...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final content = contentCtrl.text.trim();
                  if (title.isEmpty) return;

                  context.read<AppProvider>().addBusinessNote(title, content);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('নোট সফলভাবে সংরক্ষণ করা হয়েছে!')),
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
            title: const Text('ব্যবসার নোট (Notes)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFE53935),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: provider.businessNotes.isEmpty
              ? const Center(
                  child: Text('কোনো ব্যবসার নোট নেই। নতুন নোট লিখুন।', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.businessNotes.length,
                  itemBuilder: (context, index) {
                    final note = provider.businessNotes[index];
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
                              children: [
                                Checkbox(
                                  value: note.isCompleted,
                                  activeColor: Colors.green,
                                  onChanged: (_) => provider.toggleNoteStatus(note.id),
                                ),
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: note.isCompleted ? TextDecoration.lineThrough : null,
                                      color: note.isCompleted ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                  onPressed: () => provider.deleteBusinessNote(note.id),
                                ),
                              ],
                            ),
                            if (note.content.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 48, right: 12, bottom: 8),
                                child: Text(
                                  note.content,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: note.isCompleted ? Colors.grey : Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(left: 48),
                              child: Text(
                                '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddNoteDialog(context),
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.edit_note),
            label: const Text('নতুন নোট'),
          ),
        );
      },
    );
  }
}
