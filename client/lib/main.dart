import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// THE KEY: Redirects JS calls based on platform
import 'platform_stub.dart' if (dart.library.js) 'platform_js.dart' as js;

void main() => runApp(const NexusApp());

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  
  // Track the environment for UI transparency
  String currentEnv = "LOCAL_NODE"; 

  final TextEditingController _amountController = TextEditingController();
  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    _initializeTelegram();
    refreshData();
  }

  // Guarded initialization for Telegram SDK
  void _initializeTelegram() {
    if (kIsWeb) {
      try {
        if (js.context.hasProperty('Telegram')) {
          var webApp = js.context['Telegram']['WebApp'];
          
          // Verify if launch parameters exist to prevent the "No Context" crash
          var initData = webApp['initData'] ?? "";
          if (initData.toString().isNotEmpty) {
            webApp.callMethod('ready');
            setState(() => currentEnv = "TELEGRAM_MODE");
            debugPrint("Nexus: Telegram Context Verified");
          } else {
            setState(() => currentEnv = "SOVEREIGN_MOCK");
            debugPrint("Nexus: No initData, entering Mock Mode");
          }
        }
      } catch (e) {
        debugPrint("Nexus: Telegram Init suppressed: $e");
      }
    }
  }

  Future<void> refreshData() async {
    try {
      // Short timeout prevents UI hanging when browser blocks "Mixed Content"
      final healthRes = await http.get(Uri.parse("$baseUrl/health"))
          .timeout(const Duration(seconds: 3));
      
      if (healthRes.statusCode == 200) {
        final ledgerRes = await http.get(Uri.parse("$baseUrl/ledger"));
        final txRes = await http.get(Uri.parse("$baseUrl/transactions"));

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
      debugPrint("Nexus Connection Error: $e");
      setState(() {
        isBackendOnline = false;
        isLoading = false;
      });
    }
  }

  Future<void> executeSplit(double amount) async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(Uri.parse("$baseUrl/execute_split/$amount"));
      if (response.statusCode == 200) {
        _amountController.clear();
        refreshData();
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
        actions: [
          _buildStatusIndicator(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(),
    );
  }

  Widget _buildStatusIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Text(currentEnv, style: const TextStyle(fontSize: 8, color: Colors.white54)),
          const SizedBox(width: 8),
          Icon(
            Icons.circle,
            size: 12,
            color: isBackendOnline ? Colors.greenAccent : Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!isBackendOnline) _buildErrorBanner(),
          _buildMainBalance(),
          const SizedBox(height: 25),
          _buildInputSection(),
          const Divider(height: 50),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Execute Split Amount",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: isBackendOnline ? () {
            double? val = double.tryParse(_amountController.text);
            if (val != null && val > 0) executeSplit(val);
          } : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("RUN 60-30-10 EXECUTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: const Row(children: [Icon(Icons.warning, color: Colors.redAccent), SizedBox(width: 10), Expanded(child: Text("BRAIN OFFLINE: Ensure main.py is running on localhost", style: TextStyle(color: Colors.redAccent, fontSize: 12)))]),
    );
  }

  Widget _buildMainBalance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
      child: Column(children: [
        const Text("CREATOR REWARD (60%)", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600)),
        Text("\$${creatorBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_smallStat("Pool (30%)", userPoolBalance), _smallStat("Fees (10%)", protocolFees)])
      ]),
    );
  }

  Widget _smallStat(String label, double val) {
    return Column(children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)), Text("\$${val.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]);
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("RECENT VAULT ACTIVITY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return Card(
              color: Colors.white.withOpacity(0.02),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text("Split Event: \$${tx['amount']}", style: const TextStyle(fontSize: 14)),
                subtitle: Text("Vault ID: ${tx['id']}", style: const TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
              ),
            );
          },
        ),
      ],
    );
  }
}