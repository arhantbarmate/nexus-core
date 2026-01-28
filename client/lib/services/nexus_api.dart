import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http;
// FIX: Import the Safe Bridge Wrapper, not the raw Web file
import 'tg_bridge.dart';

class CursorPage {
  final List<dynamic> items;
  final Map<String, dynamic>? nextCursor;
  final String? merkleRoot;

  CursorPage({
    required this.items,
    this.nextCursor,
    this.merkleRoot,
  });
}

class NexusApi {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: "");
  static final http.Client _client = http.Client();

  static Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      "X-Nexus-TMA": TelegramBridge.initData,
      "X-Nexus-Backup-ID": TelegramBridge.userId,
    };
  }

  static Future<Map<String, dynamic>> executeSplit(double amount) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/api/execute_split"),
        headers: _getHeaders(),
        body: jsonEncode({"amount": amount}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("BRAIN_REJECTED: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("🔴 Split Error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchVaultSummary() async {
    final String uid = TelegramBridge.userId;
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/api/vault_summary/$uid"),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      debugPrint("⚠️ Vault Fetch Failed: ${response.statusCode}");
      return {
        "creator_total": 0.0, 
        "pool_total": 0.0, 
        "error": true,
        "error_code": "HTTP_${response.statusCode}"
      };
    } catch (e) {
      debugPrint("🔴 Vault Network Error: $e");
      return {
        "creator_total": 0.0, 
        "pool_total": 0.0, 
        "error": true,
        "error_code": "OFFLINE"
      };
    }
  }

  static Future<CursorPage> fetchTransactions({
    Map<String, dynamic>? cursor,
    double? minAmount,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'limit': '50',
      };

      if (cursor != null) {
        queryParams['cursor_ts'] = cursor['ts'].toString();
        queryParams['cursor_id'] = cursor['id'].toString();
      }

      if (minAmount != null) {
        queryParams['min_amount'] = minAmount.toString();
      }

      final uri = Uri.parse("$baseUrl/api/transactions")
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CursorPage(
          items: data['items'] ?? [],
          nextCursor: data['next_cursor'],
          merkleRoot: data['page_merkle_root'],
        );
      }
      return CursorPage(items: []);
    } catch (e) {
      debugPrint("🔴 Transaction Fetch Error: $e");
      return CursorPage(items: []);
    }
  }

  static void dispose() {
    _client.close();
  }
}