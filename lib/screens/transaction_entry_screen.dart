import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class TransactionEntryScreen extends StatefulWidget {
  final Customer customer;
  final bool isGot; // initial suggestion

  const TransactionEntryScreen({
    super.key,
    required this.customer,
    required this.isGot,
  });

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late bool _isGot;
  DateTime _selectedDate = DateTime.now();
  bool _hasPhotoAttached = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isGot = widget.isGot;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক টাকার পরিমাণ লিখুন')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();
    final tx = AppTransaction(
      id: '',
      customerId: widget.customer.id,
      amountGot: _isGot ? amount : 0,
      amountGave: _isGot ? 0 : amount,
      date: _selectedDate,
      note: _noteCtrl.text.trim(),
      photoUrl: _hasPhotoAttached ? 'sample_receipt_memo.jpg' : null,
    );

    final db = FirestoreDatabaseService();
    if (provider.currentUserId != null) {
      await db.addTransaction(provider.currentUserId!, tx);
      await provider.loadCustomers();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('লেনদেনের ডাটা সফলভাবে সংরক্ষিত হয়েছে!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.customer.balance;
    final isDue = balance < 0;
    final balanceText = balance == 0
        ? 'হিসাব পরিশোধিত'
        : (isDue ? 'পাবোঃ ৳${balance.abs().toStringAsFixed(2)}' : 'দেবোঃ ৳${balance.toStringAsFixed(2)}');
    final activeColor = _isGot ? Colors.green : const Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.customer.name.isNotEmpty ? widget.customer.name[0] : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customer.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    widget.customer.phone,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Current Balance status banner (matching TallyKhata)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDue ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDue ? Colors.red.shade200 : Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    balanceText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDue ? Colors.red.shade900 : Colors.green.shade900,
                    ),
                  ),
                  Text(
                    widget.customer.lastTransactionDate != null
                        ? '(${DateTime.now().difference(widget.customer.lastTransactionDate!).inDays} দিন আগে)'
                        : '(আজকের হিসাব)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dual Transaction Mode Selector (দিলাম/বেচা vs পেলাম)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isGot = false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isGot ? const Color(0xFFE53935) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: !_isGot ? const Color(0xFFE53935) : Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_upward, color: !_isGot ? Colors.white : Colors.red, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'দিলাম / বেচা',
                            style: TextStyle(
                              color: !_isGot ? Colors.white : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isGot = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isGot ? Colors.green : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isGot ? Colors.green : Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_downward, color: _isGot ? Colors.white : Colors.green, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            'পেলাম / জমা',
                            style: TextStyle(
                              color: _isGot ? Colors.white : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount Field
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
              decoration: InputDecoration(
                prefixText: '৳ ',
                labelText: _isGot ? 'পেলাম / জমার পরিমাণ' : 'দিলাম / বাকি বিক্রির পরিমাণ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Description / Note (বিবরণ)
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.edit_note_sharp),
                labelText: 'বিবরণ',
                hintText: 'লেনদেনের বিবরণ লিখুন (ঐচ্ছিক)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker & Photo Attachment Action Row (matching TallyKhata)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.date_range, size: 18, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _hasPhotoAttached = !_hasPhotoAttached);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_hasPhotoAttached ? 'মেমো / রশিদ ছবি যুক্ত হয়েছে' : 'ছবি সরানো হয়েছে'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _hasPhotoAttached ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: _hasPhotoAttached ? Colors.green : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasPhotoAttached ? Icons.check_circle : Icons.add_a_photo_outlined,
                            size: 18,
                            color: _hasPhotoAttached ? Colors.green : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _hasPhotoAttached ? 'ছবি যুক্ত' : 'ছবি',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _hasPhotoAttached ? Colors.green.shade800 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Submit Button ("নিশ্চিত")
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('নিশ্চিত করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
