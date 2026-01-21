import 'package:intl/intl.dart'; // Recommendation: for human-readable timestamps

class VaultTransaction {
  final int id;
  final String userId;
  final double amount;
  final double creatorShare;
  final double poolShare;
  final double networkFee;
  final String timestamp;

  VaultTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.creatorShare,
    required this.poolShare,
    required this.networkFee,
    required this.timestamp,
  });

  /// HIGH-LEVEL AUDIT: 
  /// The "Type-Mismatch" Stress Test: 
  /// SQLite often returns integers for whole numbers (e.g., 100). 
  /// Directly casting 'as double' causes a runtime crash. 
  /// We use '.toDouble()' on a 'num' type for absolute robustness.
  factory VaultTransaction.fromJson(Map<String, dynamic> json) {
    return VaultTransaction(
      id: json['id'] as int,
      userId: json['user_id']?.toString() ?? "UNKNOWN",
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      creatorShare: (json['creator_share'] as num? ?? 0.0).toDouble(),
      poolShare: (json['user_pool_share'] as num? ?? 0.0).toDouble(),
      networkFee: (json['network_fee'] as num? ?? 0.0).toDouble(),
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// HELPER: Formats the ISO timestamp into a readable terminal format
  String get formattedTime {
    try {
      DateTime dt = DateTime.parse(timestamp);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
    } catch (_) {
      return "00:00:00";
    }
  }
}