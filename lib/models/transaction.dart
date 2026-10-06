class AppTransaction {
  final String id;
  final String customerId;
  final double amount;
  final bool isCredit; // true = got money, false = gave money
  final DateTime date;
  final String note;

  AppTransaction({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.isCredit,
    required this.date,
    this.note = '',
  });

  factory AppTransaction.fromMap(Map<String, dynamic> data, String documentId) {
    return AppTransaction(
      id: documentId,
      customerId: data['customerId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      isCredit: data['isCredit'] ?? true,
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'amount': amount,
      'isCredit': isCredit,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
