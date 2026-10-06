import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../models/transaction.dart';

abstract class IDatabaseService {
  Future<List<Customer>> getCustomers(String userId);
  Future<void> addCustomer(String userId, Customer customer);
  Future<List<AppTransaction>> getTransactions(String customerId);
  Future<void> addTransaction(String userId, AppTransaction transaction);
}

class FirestoreDatabaseService implements IDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<Customer>> getCustomers(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('customers')
          .get();
          
      return snapshot.docs
          .map((doc) => Customer.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching customers: \$e");
      return [];
    }
  }

  @override
  Future<void> addCustomer(String userId, Customer customer) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('customers')
          .add(customer.toMap());
    } catch (e) {
      print("Error adding customer: \$e");
    }
  }

  @override
  Future<List<AppTransaction>> getTransactions(String customerId) async {
    // For transactions, we query a root collection or subcollection
    // For simplicity, let's assume a root 'transactions' collection with customerId
    try {
      final snapshot = await _db
          .collection('transactions')
          .where('customerId', isEqualTo: customerId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppTransaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching transactions: \$e");
      return [];
    }
  }

  @override
  Future<void> addTransaction(String userId, AppTransaction transaction) async {
    try {
      // Create transaction
      await _db.collection('transactions').add(transaction.toMap());
      
      // Update customer balance
      final customerRef = _db
          .collection('users')
          .doc(userId)
          .collection('customers')
          .doc(transaction.customerId);
          
      // Determine balance change. 
      // If it's credit (we got money), balance goes down (due is reduced or advance increases).
      // Assuming: positive = advance (they paid us extra), negative = due (they owe us)
      final amountChange = transaction.isCredit ? transaction.amount : -transaction.amount;
      
      await customerRef.update({
        'balance': FieldValue.increment(amountChange)
      });
    } catch (e) {
      print("Error adding transaction: \$e");
    }
  }
}
