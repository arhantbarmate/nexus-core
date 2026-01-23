import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tg_bridge_web.dart';

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
  static const String baseUrl = "";

  static Future<Map<String, dynamic>> executeSplit(double amount) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/execute_split"),
        headers: {
          "Content-Type": "application/json",
          "X-Nexus-TMA": TelegramBridge.initData,
          "X-Nexus-Backup-ID": TelegramBridge.userId,
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({"amount": amount}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("BRAIN_REJECTED: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchVaultSummary() async {
    final String uid = TelegramBridge.userId;
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/vault_summary/$uid"),
        headers: {
          "X-Nexus-TMA": TelegramBridge.initData,
          "X-Nexus-Backup-ID": uid,
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"creator_total": 0.0, "pool_total": 0.0};
    } catch (e) {
      return {"creator_total": 0.0, "pool_total": 0.0};
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

      final response = await http.get(
        uri,
        headers: {
          "X-Nexus-TMA": TelegramBridge.initData,
          "X-Nexus-Backup-ID": TelegramBridge.userId,
          "ngrok-skip-browser-warning": "true",
        },
      ).timeout(const Duration(seconds: 20));

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
      return CursorPage(items: []);
    }
  }
}