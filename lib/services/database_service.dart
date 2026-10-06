import '../models/customer.dart';
import '../models/transaction.dart';

abstract class IDatabaseService {
  Future<List<Customer>> getCustomers(String userId);
  Future<void> addCustomer(String userId, Customer customer);
  Future<List<AppTransaction>> getTransactions(String customerId);
  Future<void> addTransaction(String userId, AppTransaction transaction);
}

class FirestoreDatabaseService implements IDatabaseService {
  // TODO: Inject real FirebaseFirestore instance

  @override
  Future<List<Customer>> getCustomers(String userId) async {
    // Mock data for UI development
    return [
      Customer(id: '1', name: 'Rahim Store', phone: '01711111111', balance: 5000),
      Customer(id: '2', name: 'Karim Traders', phone: '01822222222', balance: -2000),
      Customer(id: '3', name: 'Jamil Hossain', phone: '01933333333', balance: 0),
    ];
  }

  @override
  Future<void> addCustomer(String userId, Customer customer) async {
    // Mock add
  }

  @override
  Future<List<AppTransaction>> getTransactions(String customerId) async {
    return [
      AppTransaction(id: 't1', customerId: customerId, amount: 1000, isCredit: true, date: DateTime.now().subtract(const Duration(days: 1))),
      AppTransaction(id: 't2', customerId: customerId, amount: 500, isCredit: false, date: DateTime.now()),
    ];
  }

  @override
  Future<void> addTransaction(String userId, AppTransaction transaction) async {
    // Mock add
  }
}
