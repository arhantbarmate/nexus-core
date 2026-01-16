import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- THE FIX: Bridge handles everything now ---
import 'tg_bridge.dart';

void main() {
  if (kIsWeb) {
    try {
      // Phase 1.2: Use the bridge to initialize Telegram context safely
      if (TelegramBridge.isSupported) {
        TelegramBridge.ready();
        TelegramBridge.expand();
      }
    } catch (e) {
      debugPrint("Nexus: Sovereign Mock Mode active");
    }
  }
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexus Protocol',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
      ),
      home: const NexusDashboard(),
    );
  }
}

class NexusDashboard extends StatefulWidget {
  const NexusDashboard({super.key});

  @override
  State<NexusDashboard> createState() => _NexusDashboardState();
}

class _NexusDashboardState extends State<NexusDashboard> {
  double creatorBalance = 0.0;
  double userPoolBalance = 0.0;
  double protocolFees = 0.0;
  List transactions = [];
  bool isLoading = true;
  bool isBackendOnline = false;
  bool _initialized = false;
  
  final TextEditingController _amountController = TextEditingController();

  // --- GATEWAY ROUTING ---
  String get baseUrl {
    final host = Uri.base.host;
    if (host == 'localhost' || host == '127.0.0.1') {
      return "http://127.0.0.1:8000/api";
    }
    return "${Uri.base.origin}/api"; 
  }

  @override
  void initState() {
    super.initState();
    if (!_initialized) {
      _initialized = true;
      refreshData();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Map<String, String> _getAuthHeaders() {
    if (kIsWeb) {
      try {
        // Safe access to Telegram data through the bridge
        final String initData = TelegramBridge.initData;
        if (initData.isNotEmpty) {
          return {
            'Authorization': 'tma $initData',
            'Content-Type': 'application/json',
          };
        }
      } catch (_) {}
    }
    return {'Content-Type': 'application/json'};
  }

  Future<void> refreshData() async {
    try {
      final headers = _getAuthHeaders();
      final healthUri = Uri.parse("$baseUrl/health?t=${DateTime.now().millisecondsSinceEpoch}");
      final healthRes = await http.get(healthUri).timeout(const Duration(seconds: 3));
      
      if (healthRes.statusCode == 200) {
        final ledgerRes = await http.get(Uri.parse("$baseUrl/ledger"), headers: headers);
        final txRes = await http.get(Uri.parse("$baseUrl/transactions"), headers: headers);

        if (ledgerRes.statusCode == 200 && txRes.statusCode == 200) {
          final ledgerData = json.decode(ledgerRes.body);
          setState(() {
            creatorBalance = (ledgerData['total_earned'] as num).toDouble();
            userPoolBalance = (ledgerData['global_user_pool'] as num).toDouble();
            protocolFees = (ledgerData['protocol_fees'] as num).toDouble();
            transactions = json.decode(txRes.body);
            isBackendOnline = true;
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Nexus Network Error: $e");
      setState(() {
        isBackendOnline = false;
        isLoading = false;
      });
    }
  }

  Future<void> executeSplit(double amount) async {
    setState(() => isLoading = true);
    try {
      final headers = _getAuthHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/execute_split/$amount"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Safe Haptic feedback via the bridge
        if (kIsWeb) {
          TelegramBridge.triggerHaptic();
        }
        
        _amountController.clear();
        await refreshData();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NEXUS PROTOCOL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.circle, 
              size: 12, 
              color: isBackendOnline ? Colors.greenAccent : Colors.redAccent
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: isLoading ? const Center(child: CircularProgressIndicator()) : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMainBalance(),
          const SizedBox(height: 25),
          _buildInputSection(),
          const Divider(height: 50, color: Colors.white10),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildMainBalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(children: [
        const Text("CREATOR REWARD (60%)", style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("\$${creatorBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _smallStat("Pool (30%)", userPoolBalance),
          _smallStat("Fees (10%)", protocolFees),
        ])
      ]),
    );
  }

  Widget _smallStat(String label, double val) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      const SizedBox(height: 4),
      Text("\$${val.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ]);
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            hintText: "Enter Amount",
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: isBackendOnline ? () {
            double? val = double.tryParse(_amountController.text);
            if (val != null && val > 0) executeSplit(val);
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text("RUN 60-30-10 EXECUTION", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("RECENT VAULT ACTIVITY", style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        if (transactions.isEmpty) 
          const Center(child: Text("No activity recorded", style: TextStyle(color: Colors.white24, fontSize: 12))),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.blueAccent),
                title: Text("Split Event: \$${tx['amount']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text("ID: ${tx['id']} • ${tx['timestamp'].toString().substring(11, 16)}", style: const TextStyle(fontSize: 11)),
              ),
            );
          },
        ),
      ],
    );
  }
}