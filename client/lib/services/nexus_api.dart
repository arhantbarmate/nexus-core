import 'dart:convert';
import 'package:http/http.dart' as http;
import '../tg_bridge.dart';
import '../models/vault_transaction.dart';

class NexusApi {
  static const String baseUrl = "http://localhost:8000";

  /// Phase 1.3.1 Identity Switchboard
  /// Logic: 
  /// 1. Use real Telegram initData if available.
  /// 2. If missing AND devMode is TRUE, use the mock signature.
  /// 3. Otherwise, send empty (Brain will reject with 403).
  static Map<String, String> _getHeaders({required bool devMode}) {
    final String tma = TelegramBridge.initData;

    return {
      'Content-Type': 'application/json',
      'X-Nexus-TMA': tma.isNotEmpty 
          ? tma 
          : (devMode ? 'valid_mock_signature' : ''),
    };
  }

  /// Fetches Ledger with environment-aware headers
  static Future<List<VaultTransaction>> fetchTransactions({
    required bool devMode,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions'),
        headers: _getHeaders(devMode: devMode),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((tx) => VaultTransaction.fromJson(tx)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Executes split with environment-aware headers
  static Future<Map<String, dynamic>> executeSplit(
    double amount, {
    required bool devMode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/execute_split/$amount'),
      headers: _getHeaders(devMode: devMode),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Relays the specific "IoTeX STAGED" or "Signature Failed" from the Brain
      final error = jsonDecode(response.body);
      throw error['detail'] ?? "Vault Execution Failed";
    }
  }
}