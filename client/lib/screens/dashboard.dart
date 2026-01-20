import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/nexus_api.dart';
import '../models/vault_transaction.dart';

class NexusDashboard extends StatefulWidget {
  final bool telegramReady;
  final bool devMode;

  const NexusDashboard({
    super.key,
    required this.telegramReady,
    required this.devMode,
  });

  @override
  State<NexusDashboard> createState() => _NexusDashboardState();
}

class _NexusDashboardState extends State<NexusDashboard> {
  final TextEditingController _amountController = TextEditingController(text: "100.0");
  List<VaultTransaction> _transactions = [];
  bool _isLoading = true;
  String _statusMessage = "SYSTEM IDLE";
  String _activeAdapter = "NONE";

  // --- Visual Sync Variables from index.html ---
  static const Color _colorBg = Color(0xFF0f172a);
  static const Color _colorCard = Color(0xFF1e293b);
  static const Color _colorPrimary = Color(0xFF6366f1);
  static const Color _colorText = Color(0xFFf8fafc);
  static const Color _colorMuted = Color(0xFF94a3b8);

  @override
  void initState() {
    super.initState();
    // 🛡️ Guard: Ensure environment flags match logic state
    assert(
      !(widget.devMode && !const bool.fromEnvironment('NEXUS_DEV')),
      'DEV MODE active without NEXUS_DEV flag'
    );
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
          _transactions = txs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "VAULT SYNC ERROR";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _executeVaultSplit() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _statusMessage = "INVALID AMOUNT");
      return;
    }
    setState(() => _statusMessage = "EXECUTING SPLIT...");
    try {
      final response = await NexusApi.executeSplit(amount, devMode: widget.devMode);
      if (mounted) {
        setState(() {
          _statusMessage = "EXECUTION SUCCESS";
          _activeAdapter = response['adapter']?.toString().toUpperCase() ?? "UNKNOWN";
        });
        _refreshVault();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = e.toString().toUpperCase());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBg,
      body: SingleChildScrollView(
        child: Column(
          children: [_buildNavBar(), _buildContentContainer()],
        ),
      ),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          _buildBrandHeader(),
          const SizedBox(height: 32),
          _buildStatusCard(),
          const SizedBox(height: 32),
          _buildExecutionControl(),
          const SizedBox(height: 48),
          _buildLedgerSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // 🛡️ Replaced generic icon with your official asset
        Image.asset(
          'assets/nexus-logo.png',
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            // Silence "weird" icons - just show text if asset is missing in build
            return const SizedBox(height: 100);
          },
        ),
        const SizedBox(height: 16),
        const Text("NEXUS PROTOCOL",
            style: TextStyle(color: _colorPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
        const Text("Universal Sovereign Edge Gateway",
            textAlign: TextAlign.center,
            style: TextStyle(color: _colorMuted, fontSize: 16)),
      ],
    );
  }

  // --- UI Components (NavBar, StatusCard, etc. remain visually synced to index.html) ---

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("NEXUS PROTOCOL",
              style: TextStyle(color: _colorText, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(widget.devMode ? "DEV_BYPASS" : "SOVEREIGN_NODE",
              style: const TextStyle(color: _colorMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final bool isOperational = widget.devMode || widget.telegramReady;
    final bool isStaged = _statusMessage.contains("STAGED");
    final bool isError = _statusMessage.contains("ERROR") || _statusMessage.contains("FAILED");
    final Color stateColor = isStaged ? Colors.orangeAccent : (isError ? Colors.redAccent : _colorPrimary);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _colorCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stateColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.security, color: stateColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_statusMessage,
                    style: TextStyle(color: stateColor, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                    widget.devMode
                        ? "DEV-BYPASS ACTIVE (LOGIC TEST)"
                        : (widget.telegramReady ? "Identity Linked via Sentry" : "Unauthenticated Session"),
                    style: const TextStyle(color: _colorMuted, fontSize: 12)),
              ],
            ),
          ),
          if (_activeAdapter != "NONE") _buildBadge(_activeAdapter, stateColor),
        ],
      ),
    );
  }

  Widget _buildExecutionControl() {
    final bool canExecute = (widget.devMode || widget.telegramReady) && !_statusMessage.contains("STAGED");
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _colorCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("EXECUTION GATE", style: TextStyle(color: _colorPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            style: const TextStyle(color: _colorText),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              labelText: "Amount (USD)",
              labelStyle: const TextStyle(color: _colorMuted),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canExecute ? _executeVaultSplit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("EXECUTE 60/30/10 SPLIT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("VAULT LEDGER", style: TextStyle(color: _colorPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: _colorPrimary))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = _transactions[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _colorCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TXN #${tx.id}",
                        style: const TextStyle(color: _colorText, fontWeight: FontWeight.bold)),
                    Text("\$${tx.amount.toStringAsFixed(2)}",
                        style: const TextStyle(color: _colorPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Text("© 2026 Nexus Protocol · Phase 1.3.1 Universal Gateway",
          textAlign: TextAlign.center, style: TextStyle(color: _colorMuted, fontSize: 12)),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}