import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class TransactionEntryScreen extends StatefulWidget {
  final Customer customer;
  final bool isGot;

  const TransactionEntryScreen({
    super.key,
    required this.customer,
    required this.isGot,
  });

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  String _amountString = '';
  final _noteCtrl = TextEditingController();
  bool _isLoading = false;

  void _onKeyPress(String value) {
    if (value == '<') {
      if (_amountString.isNotEmpty) {
        setState(() => _amountString = _amountString.substring(0, _amountString.length - 1));
      }
    } else {
      // Basic validation
      if (_amountString.contains('.') && value == '.') return;
      if (_amountString.length > 9) return;
      
      setState(() => _amountString += value);
    }
  }

  void _submit() async {
    final amount = double.tryParse(_amountString) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AppProvider>();
    final tx = AppTransaction(
      id: '',
      customerId: widget.customer.id,
      amountGot: widget.isGot ? amount : 0,
      amountGave: widget.isGot ? 0 : amount,
      date: DateTime.now(),
      note: _noteCtrl.text.trim(),
    );

    final db = FirestoreDatabaseService();
    await db.addTransaction(provider.currentUserId!, tx);
    await provider.loadCustomers();
    
    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isGot ? Colors.green : Colors.red;
    final title = widget.isGot ? 'You Got (Received)' : 'You Gave (Paid)';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Amount (৳)', style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    _amountString.isEmpty ? '0' : _amountString,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add Note / Details (optional)',
                      border: UnderlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          _buildKeypad(color),
        ],
      ),
    );
  }

  Widget _buildKeypad(Color color) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          children: [
            Row(children: [_buildKey('1'), _buildKey('2'), _buildKey('3')]),
            Row(children: [_buildKey('4'), _buildKey('5'), _buildKey('6')]),
            Row(children: [_buildKey('7'), _buildKey('8'), _buildKey('9')]),
            Row(children: [_buildKey('.'), _buildKey('0'), _buildKey('<', icon: Icons.backspace)]),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('SAVE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String value, {IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => _onKeyPress(value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, 2), blurRadius: 4),
              ],
            ),
            child: Center(
              child: icon != null 
                  ? Icon(icon, color: Colors.grey.shade700) 
                  : Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
