import 'package:flutter/material.dart';
import '../services/nexus_api.dart';
import '../models/vault_transaction.dart';

class NexusDashboard extends StatefulWidget {
  final bool telegramReady;
  final bool devMode;
  final String bootError;

  const NexusDashboard({
    super.key,
    required this.telegramReady,
    required this.devMode,
    required this.bootError, 
  });

  @override
  State<NexusDashboard> createState() => _NexusDashboardState();
}

class _NexusDashboardState extends State<NexusDashboard> {
  final TextEditingController _amountController = TextEditingController(text: "100.0");
  List<VaultTransaction> _transactions = [];
  bool _isLoading = true;
  String _statusMessage = "READY";
  String _activeAdapter = "NONE";

  // --- 🎨 THEME: Sovereign Slate (Matches index.html) ---
  static const Color _bg = Color(0xFF0F172A);        // Slate 900
  static const Color _card = Color(0xFF1E293B);      // Slate 800
  static const Color _primary = Color(0xFF6366F1);   // Indigo 500
  static const Color _text = Color(0xFFF8FAFC);      // Slate 50
  static const Color _subText = Color(0xFF94A3B8);   // Slate 400
  static const Color _border = Color(0x1AFFFFFF);    // White 10%
  static const Color _danger = Color(0xFFFB7185);    // Rose 400 (For Disclaimer/Errors)
  
  @override
  void initState() {
    super.initState();
    _refreshVault();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refreshVault() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final txs = await NexusApi.fetchTransactions(devMode: widget.devMode);
      if (mounted) {
        setState(() {
          _transactions = txs.take(10).toList(); 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeVaultSplit() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    
    setState(() => _statusMessage = "PROCESSING...");
    try {
      final response = await NexusApi.executeSplit(amount, devMode: widget.devMode);
      if (mounted) {
        setState(() {
          _statusMessage = "SUCCESS";
          _activeAdapter = response['adapter']?.toString().toUpperCase() ?? "UNKNOWN";
        });
        _refreshVault();
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "ERROR");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOperational = widget.devMode || widget.telegramReady;
    final bool canExecute = isOperational && !_statusMessage.contains("PROCESSING");

    return Scaffold(
      backgroundColor: _bg,
      // Custom "Nav" bar to match HTML
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _border, height: 1.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.hub, color: _primary, size: 20), // Placeholder for Logo
            const SizedBox(width: 12),
            const Text(
              "NEXUS PROTOCOL",
              style: TextStyle(
                color: _text, 
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                letterSpacing: 1.0
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                widget.devMode ? "DEV_MODE" : "LIVE NODE",
                style: TextStyle(
                  color: widget.devMode ? _danger : _primary, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 10
                ),
              ),
            ),
          )
        ],
      ),
      body: Center(
        // Constrain width for desktop/web look (Matches HTML container)
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 32),
                _buildDisclaimerPanel(isOperational),
                const SizedBox(height: 32),
                _buildControlCard(canExecute),
                const SizedBox(height: 32),
                _buildLedgerHeader(),
                const SizedBox(height: 16),
                _buildLedgerList(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Using Icon instead of Image to avoid asset loading issues for now
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.shield_moon, size: 48, color: _primary),
        ),
        const SizedBox(height: 24),
        const Text(
          "Universal Sovereign Gateway",
          textAlign: TextAlign.center,
          style: TextStyle(color: _text, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Verify-then-Execute logic for DePIN Infrastructure",
          textAlign: TextAlign.center,
          style: TextStyle(color: _subText, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDisclaimerPanel(bool isOperational) {
    // Matches the .disclaimer class in HTML
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.1), // 10% opacity background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _danger.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isOperational ? Icons.check_circle : Icons.warning_amber, color: _danger, size: 16),
              const SizedBox(width: 8),
              Text(
                "Phase 1.3.1 — ${_statusMessage}",
                style: const TextStyle(color: _danger, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (widget.bootError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "DIAGNOSTIC: ${widget.bootError}",
                style: const TextStyle(color: _danger, fontSize: 11, fontFamily: 'Courier'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlCard(bool canExecute) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("EXECUTION ENGINE", style: TextStyle(color: _primary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Initiate sovereign split transaction", style: TextStyle(color: _subText, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: _text, fontFamily: 'Courier'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bg,
                    labelText: "AMOUNT (USD)",
                    labelStyle: const TextStyle(color: _subText, fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: canExecute ? _executeVaultSplit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text("EXECUTE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        "RECENT ACTIVITY",
        style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildLedgerList() {
    if (_isLoading) return const LinearProgressIndicator(color: _primary, backgroundColor: _card);
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      separatorBuilder: (c, i) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TX_${tx.id}", style: const TextStyle(color: _danger, fontSize: 12, fontFamily: 'Courier')),
                  const SizedBox(height: 4),
                  Text("Success", style: TextStyle(color: _subText.withOpacity(0.5), fontSize: 10)),
                ],
              ),
              Text(
                "\$${tx.amount.toStringAsFixed(2)}",
                style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: _border),
        const SizedBox(height: 20),
        const Text(
          "© 2026 Nexus Protocol · Phase 1.3.1 Universal Gateway",
          style: TextStyle(color: _subText, fontSize: 12),
        ),
      ],
    );
  }
}