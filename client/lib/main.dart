import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Core',
      theme: ThemeData(primarySwatch: Colors.deepPurple, brightness: Brightness.dark),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _amountController = TextEditingController();
  
  // Data Variables
  double userPool = 0;
  double platformOps = 0;
  double community = 0;
  String status = "Ready to Split";
  List<dynamic> history = []; // The list to hold past transactions

  @override
  void initState() {
    super.initState();
    fetchHistory(); // Load history when app starts
  }

  // 1. Calculate the Split
  Future<void> fetchSplit() async {
    String amountText = _amountController.text;
    if (amountText.isEmpty) return;

    try {
      final url = Uri.parse('http://127.0.0.1:8000/split/$amountText');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userPool = data['user_60'];
          platformOps = data['ops_30'];
          community = data['community_10'];
          status = "Transaction Recorded";
          _amountController.clear(); // Clear the box
        });
        fetchHistory(); // Refresh the list immediately!
      }
    } catch (e) {
      setState(() => status = "Connection Failed");
    }
  }

  // 2. Get the List from Python
  Future<void> fetchHistory() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/history');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          history = jsonDecode(response.body);
          // Reverse the list so newest is at the top
          history = history.reversed.toList();
        });
      }
    } catch (e) {
      print("Could not fetch history");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nexus Dashboard')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // INPUT SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Revenue',
                    prefixText: '\$ ',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchSplit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                child: const Text("PROCESS TRANSACTION", style: TextStyle(color: Colors.white)),
              ),
              
              const SizedBox(height: 30),
              // VISUALS SECTION
              SplitCard("User Pool (60%)", userPool, Colors.green),
              SplitCard("Platform Ops (30%)", platformOps, Colors.blue),
              SplitCard("Community (10%)", community, Colors.orange),

              const Divider(height: 50, thickness: 2),
              const Text("Transaction Ledger", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              
              // HISTORY LIST SECTION
              Container(
                height: 300, // Limit height so it scrolls inside
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text("${item['id']}")),
                      title: Text("Revenue: \$${item['total_revenue']}"),
                      subtitle: Text("User: \$${item['user_60']} | Ops: \$${item['ops_30']} | DAO: \$${item['community_10']}"),
                      trailing: Text(item['timestamp']),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget SplitCard(String title, double amount, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      color: color.withOpacity(0.2),
      child: ListTile(
        leading: Icon(Icons.monetization_on, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}