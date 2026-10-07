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

  void _saveCustomer() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) return;

    setState(() => isLoading = true);
    
    final provider = context.read<AppProvider>();
    final customer = Customer(
      id: '', // Firestore generates this
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      balance: 0,
      userType: _userType,
    );

    final db = FirestoreDatabaseService();
    await db.addCustomer(provider.currentUserId!, customer);
    
    await provider.loadCustomers(); // refresh list
    
    setState(() => isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserType>(
              value: _userType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: UserType.customer, child: Text('Customer')),
                DropdownMenuItem(value: UserType.supplier, child: Text('Supplier')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _userType = val);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('SAVE CUSTOMER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
