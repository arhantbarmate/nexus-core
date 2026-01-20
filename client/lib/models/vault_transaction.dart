class VaultTransaction {
  final int id;
  final double amount;
  final String timestamp;

  VaultTransaction({
    required this.id, 
    required this.amount, 
    required this.timestamp
  });

  factory VaultTransaction.fromJson(Map<String, dynamic> json) {
    return VaultTransaction(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
    );
  }
}