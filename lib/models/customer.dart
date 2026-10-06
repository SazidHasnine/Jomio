class Customer {
  final String id;
  final String name;
  final String phone;
  final double balance;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0.0,
  });

  factory Customer.fromMap(Map<String, dynamic> data, String documentId) {
    return Customer(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'balance': balance,
    };
  }
}
