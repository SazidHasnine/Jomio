enum UserType { customer, supplier }

class Customer {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final UserType userType;
  final DateTime? lastTransactionDate;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0.0,
    this.userType = UserType.customer,
    this.lastTransactionDate,
  });

  factory Customer.fromMap(Map<String, dynamic> data, String documentId) {
    return Customer(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      userType: data['userType'] == 'supplier' ? UserType.supplier : UserType.customer,
      lastTransactionDate: data['lastTransactionDate'] != null ? DateTime.parse(data['lastTransactionDate']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'balance': balance,
      'userType': userType.name,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }
}
