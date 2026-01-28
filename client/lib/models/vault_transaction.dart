// Copyright 2026 Nexus Protocol Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';

/// 🏛️ VAULT TRANSACTION MODEL (Phase 1.4.0)
/// This class handles the serialization of ledger events from the Sovereign Brain.
/// Hardened to absorb malformed JSON and maintain numeric precision.
class VaultTransaction {
  final int id;
  final String userId;
  final double amount;
  final double creatorShare;
  final double poolShare;
  final double networkFee;
  final String timestamp;
  final String type;
  final String? hash; // Phase 2.0 Readiness (Merkle Proof)

  const VaultTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.creatorShare,
    required this.poolShare,
    required this.networkFee,
    required this.timestamp,
    this.type = "split",
    this.hash,
  });

  factory VaultTransaction.fromJson(final Map<String, dynamic> json) {
    // 🛡️ DATA BOUNDARY HARDENING (Audit 2.1 & 2.3)
    return VaultTransaction(
      // Defensive parsing to handle stringified SQLite IDs
      id: int.tryParse(json['id'].toString()) ?? 0,
      
      // Audit 3: Fallback aligns with Brain DEV_NAMESPACE_ID for malformed/missing rows
      userId: json['user_id']?.toString() ?? "999",
      
      // Numeric safety: Prevents 'int is not a subtype of double' crashes
      // This is critical for 10M load stability.
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      creatorShare: (json['creator_share'] as num? ?? 0.0).toDouble(),
      
      // LOGIC BRIDGE: Unifies 'user_pool_share' (Ledger) and 'pool' (Immediate Response)
      poolShare: (json['user_pool_share'] ?? json['pool'] ?? 0.0).toDouble(),
      
      networkFee: (json['network_fee'] as num? ?? 0.0).toDouble(),
      
      // Audit 2.4: Safe fallback ensures renderability without corrupting UTC baseline
      timestamp: json['timestamp'] as String? 
          ?? DateTime.now().toUtc().toIso8601String(),
          
      // Audit 4: Forward-compatible type field
      type: json['type'] as String? ?? "split",

      // Phase 2.0: Optional hash for future cryptographic verification
      hash: json['hash'] as String?,
    );
  }

  /// 🕒 PRESENTATION LAYER (Audit 5)
  /// Converts UTC ledger timestamp to local machine time for operator clarity.
  String get formattedTime {
    try {
      // NOTE: For Phase 2.0 (if list rendering becomes heavy):
      // Consider caching this as `late final DateTime _parsedTime` to avoid 
      // re-parsing on every build. For Phase 1.x, Sliver virtualization 
      // makes this optimization unnecessary (simple is safe).
      
      final dt = DateTime.parse(timestamp).toLocal(); 
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
    } catch (e) {
      // Fail silent in Prod to avoid UI flicker
      if (kDebugMode) debugPrint("🏛️ [Model] Timestamp_Parse_Error: $e");
      return "00:00:00";
    }
  }
}