import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../providers/app_provider.dart';

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
    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  void _addTransaction(bool isCredit) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCredit ? 'You Got (Received)' : 'You Gave (Credit)'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (৳)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount <= 0) return;

              final provider = context.read<AppProvider>();
              final tx = AppTransaction(
                id: '', 
                customerId: widget.customer.id, 
                amount: amount, 
                isCredit: isCredit, 
                date: DateTime.now()
              );
              
              Navigator.pop(context);
              setState(() => isLoading = true);
              
              await _db.addTransaction(provider.currentUserId!, tx);
              await provider.loadCustomers(); // Update balances on home
              await _loadTransactions();
            },
            child: const Text('SAVE'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.isCredit ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward, 
                      color: tx.isCredit ? Colors.green : Colors.red),
                ),
                title: Text(tx.isCredit ? 'Got' : 'Gave', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("\${tx.date.day}/\${tx.date.month}/\${tx.date.year}"),
                trailing: Text(
                  "৳ \${tx.amount}", 
                  style: TextStyle(
                    color: tx.isCredit ? Colors.green : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addTransaction(false), // False = Gave
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('GAVE ৳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addTransaction(true), // True = Got
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('GOT ৳', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
