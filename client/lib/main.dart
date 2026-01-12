import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const NexusApp());

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
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
  double balance = 0.0;
  List transactions = [];
  bool isLoading = true;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> refreshData() async {
    try {
      final ledgerRes =
          await http.get(Uri.parse("http://127.0.0.1:8000/ledger"));
      final txRes =
          await http.get(Uri.parse("http://127.0.0.1:8000/transactions"));

      if (ledgerRes.statusCode == 200 && txRes.statusCode == 200) {
        setState(() {
          balance =
              (json.decode(ledgerRes.body)['total_earned'] as num).toDouble();
          transactions = json.decode(txRes.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> executeSplit(double amount) async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/execute_split/$amount"),
    );

    if (response.statusCode == 200) {
      _amountController.clear();
      refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("NEXUS PROTOCOL - ARHAN")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // CREATOR BALANCE
            Card(
              color: Colors.blueGrey[900],
              child: ListTile(
                title: const Text(
                  "CREATOR REWARD (60%)",
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  balance.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AMOUNT INPUT
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Amount",
                  hintText: "e.g. 1000",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // EXECUTE SPLIT
            ElevatedButton(
              onPressed: () {
                final input = _amountController.text.trim();
                if (input.isEmpty) return;

                final amount = double.tryParse(input);
                if (amount == null || amount <= 0) return;

                executeSplit(amount);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "EXECUTE 60-30-10 SPLIT",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const Divider(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "TRANSACTION HISTORY",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // TRANSACTIONS
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text("No transactions yet"))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final timeStr = tx['timestamp'].toString();
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.receipt_long,
                              color: Colors.blueAccent,
                            ),
                            title: Text("Split: +${tx['amount']}"),
                            subtitle: Text(
                              "Time: ${timeStr.replaceFirst('T', ' ').substring(0, 16)}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
