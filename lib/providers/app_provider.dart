import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/business_utility_models.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

enum CustomerFilter { all, customersOnly, suppliersOnly, dueOnly, advanceOnly }

class AppProvider with ChangeNotifier {
  final IDatabaseService _db;
  final IAuthService _auth;

  List<Customer> customers = [];
  String? currentUserId;
  bool isLoading = false;

  // Search & Filter state
  String _searchQuery = '';
  CustomerFilter _currentFilter = CustomerFilter.all;

  String get searchQuery => _searchQuery;
  CustomerFilter get currentFilter => _currentFilter;

  // Business Profile Info
  String _businessName = 'মেসার্স জমিও ট্রেডার্স';
  String _businessType = 'মুদি ও জেনারেল স্টোর';
  String _businessPhone = '+880 1712 345678';
  String get businessName => _businessName;
  String get businessType => _businessType;
  String get businessPhone => _businessPhone;

  List<BusinessProfile> businesses = [
    BusinessProfile(id: '1', name: 'মেসার্স জমিও ট্রেডার্স', type: 'মুদি ও জেনারেল স্টোর', phone: '+880 1712 345678', isSelected: true),
    BusinessProfile(id: '2', name: 'জমিও ইলেকট্রনিক্স', type: 'পাইকারি ও খুচরা বিক্রেতা', phone: '+880 1819 876543', isSelected: false),
  ];

  // Cashbox Data
  List<CashEntry> cashEntries = [
    CashEntry(
      id: '1',
      amount: 5000.0,
      isCashIn: true,
      description: 'দিনের প্রারম্ভিক ক্যাশ',
      date: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    CashEntry(
      id: '2',
      amount: 1200.0,
      isCashIn: true,
      description: 'নগদ বিক্রি',
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CashEntry(
      id: '3',
      amount: 800.0,
      isCashIn: false,
      description: 'দোকান ভাড়া ও খরচ',
      date: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // Stock / Inventory Data
  List<StockItem> stockItems = [
    StockItem(id: '1', name: 'মিনিকেট চাল ২৫ কেজি', quantity: 24, buyPrice: 1750, sellPrice: 1900, unit: 'বস্তা'),
    StockItem(id: '2', name: 'তীর সয়াবিন তেল ৫ লিটার', quantity: 15, buyPrice: 880, sellPrice: 940, unit: 'বোতল'),
    StockItem(id: '3', name: 'ফ্রেশ আটা ২ কেজি', quantity: 40, buyPrice: 120, sellPrice: 140, unit: 'প্যাকেট'),
    StockItem(id: '4', name: 'চিনি ১ কেজি', quantity: 8, buyPrice: 130, sellPrice: 145, unit: 'কেজি'),
  ];

  // Business Notes Data
  List<BusinessNote> businessNotes = [
    BusinessNote(
      id: '1',
      title: 'চাল ও তেলের অর্ডার',
      content: 'আগামীকাল সকালে মেসার্স রহিম ট্রেডার্সকে নতুন চাল ও তেলের সাপ্লাই দিতে হবে।',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: false,
    ),
    BusinessNote(
      id: '2',
      title: 'বিদ্যুৎ বিল পরিশোধ',
      content: 'এই মাসের দোকান বিল ১৫ তারিখের মধ্যে বিকাশ থেকে দিতে হবে।',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isCompleted: true,
    ),
  ];

  // Backup state
  DateTime lastBackupTime = DateTime.now().subtract(const Duration(hours: 4));
  bool isBackingUp = false;

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
      
      final dbCash = await _db.getCashEntries(currentUserId!);
      if (dbCash.isNotEmpty) cashEntries = dbCash;

      final dbStock = await _db.getStockItems(currentUserId!);
      if (dbStock.isNotEmpty) stockItems = dbStock;

      final dbNotes = await _db.getBusinessNotes(currentUserId!);
      if (dbNotes.isNotEmpty) businessNotes = dbNotes;
    } catch (e) {
      debugPrint("Error loading data from Firestore: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Search & Filter controls
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(CustomerFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<Customer> get filteredCustomers {
    return customers.where((c) {
      // Filter by type or balance
      switch (_currentFilter) {
        case CustomerFilter.customersOnly:
          if (c.userType != UserType.customer) return false;
          break;
        case CustomerFilter.suppliersOnly:
          if (c.userType != UserType.supplier) return false;
          break;
        case CustomerFilter.dueOnly:
          if (c.balance >= 0) return false; // Due means balance < 0 (or owe money)
          break;
        case CustomerFilter.advanceOnly:
          if (c.balance <= 0) return false; // Advance/receive means balance > 0
          break;
        case CustomerFilter.all:
          break;
      }

      // Filter by search query
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();
      return c.name.toLowerCase().contains(query) || c.phone.contains(query);
    }).toList();
  }

  int get customerCount => customers.where((c) => c.userType == UserType.customer).length;
  int get supplierCount => customers.where((c) => c.userType == UserType.supplier).length;

  double get totalGive {
    return customers.where((c) => c.balance < 0).fold(0, (sum, c) => sum + c.balance.abs());
  }

  double get totalGet {
    return customers.where((c) => c.balance > 0).fold(0, (sum, c) => sum + c.balance);
  }

  // Cashbox operations
  double get totalCashIn => cashEntries.where((e) => e.isCashIn).fold(0, (sum, e) => sum + e.amount);
  double get totalCashOut => cashEntries.where((e) => !e.isCashIn).fold(0, (sum, e) => sum + e.amount);
  double get cashInHand => totalCashIn - totalCashOut;

  void addCashEntry(double amount, bool isCashIn, String description) {
    final entry = CashEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      isCashIn: isCashIn,
      description: description.isEmpty ? (isCashIn ? 'ক্যাশ ইন' : 'ক্যাশ আউট') : description,
      date: DateTime.now(),
    );
    cashEntries.insert(0, entry);
    notifyListeners();

    if (currentUserId != null) {
      _db.addCashEntry(currentUserId!, entry);
    }
  }

  // Stock operations
  double get totalStockValuation => stockItems.fold(0, (sum, item) => sum + item.totalValue);
  int get totalStockQuantity => stockItems.fold(0, (sum, item) => sum + item.quantity);

  void addStockItem(String name, int quantity, double buyPrice, double sellPrice, String unit) {
    final item = StockItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      unit: unit,
    );
    stockItems.insert(0, item);
    notifyListeners();

    if (currentUserId != null) {
      _db.addStockItem(currentUserId!, item);
    }
  }

  void updateStockQuantity(String id, int delta) {
    final idx = stockItems.indexWhere((item) => item.id == id);
    if (idx != -1) {
      final current = stockItems[idx];
      final newQty = (current.quantity + delta).clamp(0, 999999);
      stockItems[idx] = StockItem(
        id: current.id,
        name: current.name,
        quantity: newQty,
        buyPrice: current.buyPrice,
        sellPrice: current.sellPrice,
        unit: current.unit,
      );
      notifyListeners();

      if (currentUserId != null) {
        _db.updateStockQuantity(currentUserId!, id, newQty);
      }
    }
  }

  void deleteStockItem(String id) {
    stockItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Business Notes operations
  void addBusinessNote(String title, String content) {
    final note = BusinessNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    businessNotes.insert(0, note);
    notifyListeners();

    if (currentUserId != null) {
      _db.addBusinessNote(currentUserId!, note);
    }
  }

  void toggleNoteStatus(String id) {
    final idx = businessNotes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final old = businessNotes[idx];
      final newCompleted = !old.isCompleted;
      businessNotes[idx] = BusinessNote(
        id: old.id,
        title: old.title,
        content: old.content,
        createdAt: old.createdAt,
        isCompleted: newCompleted,
      );
      notifyListeners();

      if (currentUserId != null) {
        _db.updateBusinessNote(currentUserId!, id, newCompleted);
      }
    }
  }

  void deleteBusinessNote(String id) {
    businessNotes.removeWhere((n) => n.id == id);
    notifyListeners();

    if (currentUserId != null) {
      _db.deleteBusinessNote(currentUserId!, id);
    }
  }

  // Multi-Business operations
  void switchBusiness(String id) {
    for (int i = 0; i < businesses.length; i++) {
      final b = businesses[i];
      if (b.id == id) {
        businesses[i] = BusinessProfile(id: b.id, name: b.name, type: b.type, phone: b.phone, isSelected: true);
        _businessName = b.name;
        _businessType = b.type;
        _businessPhone = b.phone;
      } else {
        businesses[i] = BusinessProfile(id: b.id, name: b.name, type: b.type, phone: b.phone, isSelected: false);
      }
    }
    notifyListeners();
  }

  void addBusiness(String name, String type, String phone) {
    final newB = BusinessProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      phone: phone,
      isSelected: false,
    );
    businesses.add(newB);
    notifyListeners();
  }

  void updateCurrentBusinessName(String name) {
    _businessName = name;
    notifyListeners();
  }

  // Cloud Backup Trigger
  Future<void> triggerBackup() async {
    isBackingUp = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    lastBackupTime = DateTime.now();
    isBackingUp = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    customers.clear();
    currentUserId = null;
    notifyListeners();
  }
}
