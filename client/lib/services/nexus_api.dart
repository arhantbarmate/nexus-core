import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// AUDIT FIX: Import your bridge, not the raw package, to prevent Desktop crashes.
import 'tg_bridge.dart'; 

class VaultSummary {
  final double creatorTotal;
  final double poolTotal;

  VaultSummary({required this.creatorTotal, required this.poolTotal});

  factory VaultSummary.empty() => VaultSummary(creatorTotal: 0.0, poolTotal: 0.0);
}

class NexusApi {
  static String get _baseUrl {
    const url = String.fromEnvironment(
      'NEXUS_API_URL', 
      defaultValue: 'http://localhost:8000/api'
    );
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// HIGH-LEVEL AUDIT: 
  /// Uses the Bridge to extract identity. This prevents "Unsupported Operation" 
  /// errors when testing the UI on Desktop/IDE.
  static Map<String, String> _getAuthHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // 1. Secure TMA Signature via Bridge
    final String tmaData = TelegramBridge.initData;
    if (tmaData.isNotEmpty) {
      headers['X-Nexus-TMA'] = tmaData;
    }

    // 2. Identity Rescue via Bridge (Matches main.py resolve_sovereign_id)
    final String uid = TelegramBridge.userId;
    if (uid != "LOCAL_HOST") {
      headers['X-Nexus-Backup-ID'] = uid;
    }

    return headers;
  }

  // --- 🧠 1. FETCH VAULT SUMMARY ---
  static Future<VaultSummary> fetchVaultSummary({required bool devMode}) async {
    // Audit: Use the bridge-resolved ID for the path
    final String uid = TelegramBridge.userId;

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/vault_summary/$uid"),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // STRESS TEST FIX: Robust type handling for SQLite dynamic types
        return VaultSummary(
          creatorTotal: (data['creator_total'] as num? ?? 0.0).toDouble(),
          poolTotal: (data['pool_total'] as num? ?? 0.0).toDouble(),
        );
      }
    } catch (e) {
      debugPrint("🏛️ [API] Vault_Sync_Failure: $e");
    }
    return VaultSummary.empty();
  }

  // --- 🚀 2. EXECUTE VAULT SPLIT ---
  static Future<Map<String, dynamic>> executeSplit(double amount, {required bool devMode}) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/execute_split/$amount"),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // High-Level Audit: Graceful rejection parsing
        String msg = "VAULT_REJECTION";
        try {
          final err = json.decode(response.body);
          msg = err['detail'] ?? msg;
        } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      debugPrint("🏛️ [API] Protocol_Execution_Error: $e");
      rethrow;
    }
  }

  // --- 📜 3. FETCH TRANSACTIONS ---
  static Future<List<dynamic>> fetchTransactions({required bool devMode}) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/transactions"),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
    } catch (e) {
      debugPrint("🏛️ [API] Ledger_Sync_Error: $e");
    }
    return [];
  }
}