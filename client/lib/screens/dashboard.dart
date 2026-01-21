import 'package:flutter/material.dart';
import 'dart:async';
import '../services/nexus_api.dart';
import '../models/vault_transaction.dart';
import '../services/tg_bridge.dart';

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
  // ignore: unused_field
  List<dynamic> _transactions = [];
  
  double _creatorTotal = 0.0;
  double _poolTotal = 0.0;
  
  bool _isLoading = true;
  bool _isExecuting = false;
  String _statusMessage = "BOOTING_CORE";

  // --- 🎨 MACHINE THEME ---
  static const Color _bg = Color(0xFF050508);
  static const Color _surface = Color(0xFF0D0D12);
  static const Color _primary = Color(0xFF4F46E5);
  static const Color _terminal = Color(0xFF10B981); 
  static const Color _error = Color(0xFFEF4444);
  static const Color _border = Color(0xFF1F1F2E);

  @override
  void initState() {
    super.initState();
    if (widget.bootError.isNotEmpty) {
      _statusMessage = "BOOT_FAILURE: ${widget.bootError}";
      _isLoading = false;
    } else {
      _syncSovereignState();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // --- 🧠 LOGIC: Hardened State Sync ---
  Future<void> _syncSovereignState() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = "SYNCING_WITH_BRAIN";
    });
    
    try {
      final List<dynamic> results = await Future.wait([
        NexusApi.fetchVaultSummary(devMode: widget.devMode),
        NexusApi.fetchTransactions(devMode: widget.devMode),
      ]).timeout(const Duration(seconds: 10));

      final VaultSummary summary = results[0] as VaultSummary;
      final List<dynamic> rawTxs = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _transactions = rawTxs
              .map((json) => VaultTransaction.fromJson(json as Map<String, dynamic>))
              .toList();
          
          _creatorTotal = summary.creatorTotal;
          _poolTotal = summary.poolTotal;
          _statusMessage = "SYSTEM_STABLE";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "SYNC_FAILURE_RETRYING");
      Future.delayed(const Duration(seconds: 5), _syncSovereignState);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeSequence() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
       setState(() => _statusMessage = "INVALID_MAGNITUDE");
       return;
    }
    
    if (_isExecuting) return;

    setState(() {
      _isExecuting = true;
      _statusMessage = "VAULT_TRANSFER_IN_PROGRESS";
    });

    try {
      TelegramBridge.triggerHaptic();
      await NexusApi.executeSplit(amount, devMode: widget.devMode);
      
      if (mounted) {
        setState(() => _statusMessage = "BLOCK_COMMITTED");
        await Future.delayed(const Duration(milliseconds: 800)); // Settle delay
        await _syncSovereignState();
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isExecuting = false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExecuting = false;
          _statusMessage = "SENTRY_REJECTED";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isLoading ? 0.5 : 1.0,
            child: _buildMainFrame(),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFrame() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isExecuting ? _primary : _border, width: 2),
        boxShadow: [
          BoxShadow(
            color: _isExecuting ? _primary.withOpacity(0.1) : Colors.transparent,
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildTelemetry(),
          _buildVaultSummary(),
          _buildControlPanel(),
          _buildConsole(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("NODE_STATUS: ${widget.telegramReady ? 'SOVEREIGN' : 'LOCAL'}",
              style: const TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
          _buildPulseIndicator(),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return Container(
      height: 8, width: 8,
      decoration: BoxDecoration(
        color: _isLoading ? Colors.orange : _terminal,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: (_isLoading ? Colors.orange : _terminal).withOpacity(0.3), blurRadius: 6)],
      ),
    );
  }

  Widget _buildTelemetry() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _teleRow("OPERATOR_ID", TelegramBridge.userId),
          _teleRow("AUTH_MODE", widget.telegramReady ? "TMA_SECURE" : "MOCK_MODE"),
        ],
      ),
    );
  }

  Widget _buildVaultSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _vaultStat("CREATOR (60%)", _creatorTotal, _primary),
          _vaultStat("POOL (30%)", _poolTotal, _terminal),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
  controller: _amountController,
  // FIX: inputmode (web) is handled via keyboardType in Flutter
  keyboardType: const TextInputType.numberWithOptions(decimal: true), 
  style: const TextStyle(color: _terminal, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              labelText: "SPLIT_MAGNITUDE",
              labelStyle: TextStyle(color: Colors.white24, fontSize: 10),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _border)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isExecuting ? null : _executeSequence,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _border,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(_isExecuting ? "EXECUTING..." : "INIT_EXECUTION",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsole() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
      child: Text("> $_statusMessage",
          style: TextStyle(color: _statusMessage.contains("FAILURE") ? _error : Colors.white24, fontSize: 9, fontFamily: 'monospace')),
    );
  }

  Widget _teleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white12, fontSize: 9)),
          Text(value, style: const TextStyle(color: _terminal, fontSize: 9, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _vaultStat(String label, double val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8)),
        const SizedBox(height: 4),
        Text("${val.toStringAsFixed(2)}U",
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}