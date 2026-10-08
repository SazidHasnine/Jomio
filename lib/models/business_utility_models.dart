class CashEntry {
  final String id;
  final double amount;
  final bool isCashIn; // true: Cash In, false: Cash Out
  final String description;
  final DateTime date;

  CashEntry({
    required this.id,
    required this.amount,
    required this.isCashIn,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'isCashIn': isCashIn,
    'description': description,
    'date': date.toIso8601String(),
  };

  factory CashEntry.fromMap(Map<String, dynamic> map, String id) => CashEntry(
    id: id,
    amount: (map['amount'] ?? 0).toDouble(),
    isCashIn: map['isCashIn'] ?? true,
    description: map['description'] ?? '',
    date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
  );
}

class StockItem {
  final String id;
  final String name;
  final int quantity;
  final double buyPrice;
  final double sellPrice;
  final String unit; // e.g. 'টি' (pcs), 'কেজি' (kg), 'লিটার' (ltr)

  StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    this.unit = 'টি',
  });

  double get totalValue => quantity * buyPrice;

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'unit': unit,
  };

  factory StockItem.fromMap(Map<String, dynamic> map, String id) => StockItem(
    id: id,
    name: map['name'] ?? '',
    quantity: (map['quantity'] ?? 0) as int,
    buyPrice: (map['buyPrice'] ?? 0).toDouble(),
    sellPrice: (map['sellPrice'] ?? 0).toDouble(),
    unit: map['unit'] ?? 'টি',
  );
}

class BusinessNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isCompleted;

  BusinessNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory BusinessNote.fromMap(Map<String, dynamic> map, String id) => BusinessNote(
    id: id,
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    isCompleted: map['isCompleted'] ?? false,
  );
}

class BusinessProfile {
  final String id;
  final String name;
  final String type; // e.g. মুদি দোকান, ফার্মেসি, পাইকারি
  final String phone;
  final bool isSelected;

  BusinessProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    this.isSelected = false,
  });
}
