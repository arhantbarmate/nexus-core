import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tg_bridge_web.dart';

/// 🧠 NEXUS CORE API
/// The authoritative communication layer between the Flutter Body and Python Brain.
class NexusApi {
  // Configured for local Sovereign Node execution
  static const String baseUrl = "http://localhost:8000";

  /// 🛰️ EXECUTE SPLIT PROTOCOL
  /// Communicates with the Sovereign Brain to trigger a 60/30/10 split.
  /// devMode parameter added to match Dashboard call signature.
  static Future<Map<String, dynamic>> executeSplit(double amount, {bool? devMode}) async {
    final String tmaData = TelegramBridge.initData; 
    final String uid = TelegramBridge.userId;       

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/execute_split"),
        headers: {
          "Content-Type": "application/json",
          "X-Nexus-TMA": tmaData,        
          "X-Nexus-Backup-ID": uid,      
          "ngrok-skip-browser-warning": "true", 
        },
        body: jsonEncode({"amount": amount}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("BRAIN_REJECTED: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 🏛️ FETCH VAULT SUMMARY
  /// Retrieves total liquidity for the current Operator.
  /// Renamed from 'getVaultSummary' to satisfy Dashboard requirement.
  static Future<Map<String, dynamic>> fetchVaultSummary({bool? devMode}) async {
    final String uid = TelegramBridge.userId;
    
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/vault_summary/$uid"),
        headers: {
          "X-Nexus-TMA": TelegramBridge.initData,
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception("VAULT_READ_ERROR");
    } catch (e) {
      // Returns zeroed state on connection failure to prevent UI crash
      return {"creator_total": 0.0, "pool_total": 0.0};
    }
  }

  /// 📜 FETCH LEDGER HISTORY
  /// Retrieves the last 50 transactions for the authenticated namespace.
  /// Renamed from 'getTransactions' to satisfy Dashboard requirement.
  static Future<List<dynamic>> fetchTransactions({bool? devMode}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/transactions"),
        headers: {
          "X-Nexus-TMA": TelegramBridge.initData,
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}