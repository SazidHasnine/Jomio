import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class AppProvider with ChangeNotifier {
  final IDatabaseService _db;
  final IAuthService _auth;

  List<Customer> customers = [];
  String? currentUserId;
  bool isLoading = false;

  AppProvider(this._auth, this._db) {
    _auth.authStateChanges.listen((userId) {
      currentUserId = userId;
      if (userId != null) {
        loadCustomers();
      }
    });
  }

  Future<void> loadCustomers() async {
    if (currentUserId == null) return;
    
    isLoading = true;
    notifyListeners();

    try {
      customers = await _db.getCustomers(currentUserId!);
    } catch (e) {
      debugPrint("Error loading customers: \$e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get totalGive {
    return customers.where((c) => c.balance < 0).fold(0, (sum, c) => sum + c.balance.abs());
  }

  double get totalGet {
    return customers.where((c) => c.balance > 0).fold(0, (sum, c) => sum + c.balance);
  }

  Future<void> logout() async {
    await _auth.logout();
    customers.clear();
    currentUserId = null;
    notifyListeners();
  }
}
