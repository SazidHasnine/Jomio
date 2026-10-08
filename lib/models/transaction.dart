class AppTransaction {
  final String id;
  final String customerId;
  final double amountGot;
  final double amountGave;
  final DateTime date;
  final String note;
  final String? photoUrl;

  AppTransaction({
    required this.id,
    required this.customerId,
    this.amountGot = 0.0,
    this.amountGave = 0.0,
    required this.date,
    this.note = '',
    this.photoUrl,
  });

  factory AppTransaction.fromMap(Map<String, dynamic> data, String documentId) {
    return AppTransaction(
      id: documentId,
      customerId: data['customerId'] ?? '',
      amountGot: (data['amountGot'] ?? 0).toDouble(),
      amountGave: (data['amountGave'] ?? 0).toDouble(),
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      note: data['note'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'amountGot': amountGot,
      'amountGave': amountGave,
      'date': date.toIso8601String(),
      'note': note,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
