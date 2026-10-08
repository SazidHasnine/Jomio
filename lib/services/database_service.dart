import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/business_utility_models.dart';

abstract class IDatabaseService {
  Future<List<Customer>> getCustomers(String userId);
  Future<void> addCustomer(String userId, Customer customer);
  Future<List<AppTransaction>> getTransactions(String customerId);
  Future<void> addTransaction(String userId, AppTransaction transaction);

  // Business Utilities persistence
  Future<List<CashEntry>> getCashEntries(String userId);
  Future<void> addCashEntry(String userId, CashEntry entry);

  Future<List<StockItem>> getStockItems(String userId);
  Future<void> addStockItem(String userId, StockItem item);
  Future<void> updateStockQuantity(String userId, String itemId, int newQuantity);

  Future<List<BusinessNote>> getBusinessNotes(String userId);
  Future<void> addBusinessNote(String userId, BusinessNote note);
  Future<void> updateBusinessNote(String userId, String noteId, bool isCompleted);
  Future<void> deleteBusinessNote(String userId, String noteId);
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
    } catch (_) {
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
    } catch (_) {}
  }

  @override
  Future<List<AppTransaction>> getTransactions(String customerId) async {
    try {
      final snapshot = await _db
          .collection('transactions')
          .where('customerId', isEqualTo: customerId)
          .get();

      final list = snapshot.docs
          .map((doc) => AppTransaction.fromMap(doc.data(), doc.id))
          .toList();
      
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addTransaction(String userId, AppTransaction transaction) async {
    try {
      await _db.collection('transactions').add(transaction.toMap());
      
      final customerRef = _db
          .collection('users')
          .doc(userId)
          .collection('customers')
          .doc(transaction.customerId);
          
      final amountChange = transaction.amountGot - transaction.amountGave;
      
      await customerRef.update({
        'balance': FieldValue.increment(amountChange),
        'lastTransactionDate': transaction.date.toIso8601String(),
      });
    } catch (_) {}
  }

  // Cashbox Firestore operations
  @override
  Future<List<CashEntry>> getCashEntries(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('cashbox')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => CashEntry.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addCashEntry(String userId, CashEntry entry) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('cashbox')
          .add(entry.toMap());
    } catch (_) {}
  }

  // Stock Firestore operations
  @override
  Future<List<StockItem>> getStockItems(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('stock')
          .get();
      return snapshot.docs.map((doc) => StockItem.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addStockItem(String userId, StockItem item) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('stock')
          .add(item.toMap());
    } catch (_) {}
  }

  @override
  Future<void> updateStockQuantity(String userId, String itemId, int newQuantity) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('stock')
          .doc(itemId)
          .update({'quantity': newQuantity});
    } catch (_) {}
  }

  // Business Notes Firestore operations
  @override
  Future<List<BusinessNote>> getBusinessNotes(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => BusinessNote.fromMap(doc.data(), doc.id)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addBusinessNote(String userId, BusinessNote note) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notes')
          .add(note.toMap());
    } catch (_) {}
  }

  @override
  Future<void> updateBusinessNote(String userId, String noteId, bool isCompleted) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .update({'isCompleted': isCompleted});
    } catch (_) {}
  }

  @override
  Future<void> deleteBusinessNote(String userId, String noteId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (_) {}
  }
}
