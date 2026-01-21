// Copyright 2026 Nexus Protocol Authors (Apache 2.0)
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/nexus_api.dart';
import '../models/vault_transaction.dart';
import '../services/tg_bridge_web.dart'; // Sync: Using the web-specific bridge

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

class _NexusDashboardState extends State<NexusDashboard> with WidgetsBindingObserver {
  final TextEditingController _amountController = TextEditingController(text: "100.00");
  List<VaultTransaction> _transactions = [];
  
  double _creatorTotal = 0.0;
  double _poolTotal = 0.0;
  
  bool _isLoading = true;
  bool _isExecuting = false;
  bool _retryScheduled = false; 
  String _statusMessage = "BOOTING_CORE";

  // --- 🎨 MACHINE THEME (Sleek Dark) ---
  static const Color _bg = Color(0xFF020204);
  static const Color _surface = Color(0xFF0A0A0F);
  static const Color _primary = Color(0xFF6366F1);
  static const Color _terminal = Color(0xFF10B981); 
  static const Color _error = Color(0xFFFB7185);
  static const Color _border = Color(0xFF1E1E26);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.bootError.isNotEmpty) {
      _statusMessage = "BOOT_FAILURE: ${widget.bootError}";
      _isLoading = false;
    } else {
      _syncSovereignState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncSovereignState(); // Refresh ledger on resume
    }
  }

  // --- 🧠 HARDENED LOGIC (Audit 2.2 & 5) ---

  Future<void> _syncSovereignState() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = "SYNCING_WITH_BRAIN";
    });
    
    try {
      // Parallel fetch ensures deterministic ledger synchronization
      final results = await Future.wait([
        NexusApi.fetchVaultSummary(devMode: widget.devMode),
        NexusApi.fetchTransactions(devMode: widget.devMode),
      ]).timeout(const Duration(seconds: 10));

      final summary = results[0];
      final rawTxs = results[1];

      // Audit Fix: Replaced 'is VaultSummary' with 'is Map' to match API return type
      if (mounted && summary is Map && summary.containsKey('creator_total')) {
        setState(() {
          _creatorTotal = (summary['creator_total'] as num).toDouble();
          _poolTotal = (summary['pool_total'] as num).toDouble();
          // ... rest of the logic
        });
      } else {
        // Audit: If the Brain returns a 404 or error, default to zeroed state
        setState(() {
          _creatorTotal = 0.0;
          _poolTotal = 0.0;
          _statusMessage = "VAULT_EMPTY_OR_UNREACHABLE";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = "SYNC_FAILURE_RETRYING");
        
        if (!_retryScheduled) {
          _retryScheduled = true;
          Future.delayed(const Duration(seconds: 5), () {
            _retryScheduled = false;
            if (mounted) _syncSovereignState();
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _executeSequence() async {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || amount.isNaN || amount.isInfinite) {
       setState(() => _statusMessage = "INVALID_MAGNITUDE");
       return;
    }
    
    if (_isExecuting) return;
    setState(() {
      _isExecuting = true;
      _statusMessage = "VAULT_TRANSFER_IN_PROGRESS";
    });

    try {
      // Audit: Tactile feedback signal
      TelegramBridge.triggerHaptic();
      
      // Sync: executeSplit now accepts named devMode parameter
      await NexusApi.executeSplit(amount, devMode: widget.devMode);
      
      if (mounted) {
        setState(() => _statusMessage = "BLOCK_COMMITTED");
        // UX: Intentional delay for Real-Time Grow impact
        await Future.delayed(const Duration(milliseconds: 1200)); 
        await _syncSovereignState();
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "SENTRY_REJECTED");
    } finally {
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () => setState(() => _isExecuting = false));
      }
    }
  }

  // --- 🎨 UI ARCHITECTURE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildVaultCard(),
                      const SizedBox(height: 20),
                      _buildControlPanel(),
                      const SizedBox(height: 20),
                      _buildLedger(),
                    ],
                  ),
                ),
              ),
              _buildConsole(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NEXUS_PROTOCOL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
            Text("OPERATOR_ID: ${TelegramBridge.userId}", style: const TextStyle(color: Colors.white24, fontSize: 9, fontFamily: 'monospace')),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: _primary.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)),
          child: Text(widget.telegramReady ? "SOVEREIGN" : "LOCAL", style: const TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildVaultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Text("TOTAL_VAULT_LIQUIDITY", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text("${(_creatorTotal + _poolTotal).toStringAsFixed(2)} U", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const Divider(height: 40, color: _border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _vaultStat("CREATOR (60%)", _creatorTotal, _primary),
              _vaultStat("POOL (30%)", _poolTotal, _terminal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isExecuting ? _primary : _border)),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(color: _terminal, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(color: Colors.white10),
              border: InputBorder.none,
              prefixText: "SPLIT_AMT: ",
              prefixStyle: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isExecuting || _isLoading ? null : _executeSequence,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isExecuting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("EXECUTE_PROTOCOL_SPLIT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLedger() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text("SOVEREIGN_LEDGER", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        // Display last 5 entries from local vault state
        ..._transactions.take(5).map((tx) => _buildTxRow(tx)).toList(),
      ],
    );
  }

  Widget _buildTxRow(VaultTransaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.type.toUpperCase(), style: TextStyle(color: tx.type == "split" ? _terminal : _primary, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(tx.formattedTime, style: const TextStyle(color: Colors.white12, fontSize: 8)), // Audit Fix: Using formattedTime
            ],
          ),
          Text("+${tx.amount.toStringAsFixed(2)} U", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildConsole() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: _border))),
      child: Text("> $_statusMessage", style: TextStyle(color: _statusMessage.contains("FAILURE") || _statusMessage.contains("REJECTED") ? _error : _terminal.withOpacity(0.7), fontSize: 10, fontFamily: 'monospace')),
    );
  }

  Widget _vaultStat(String label, double val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9)),
        const SizedBox(height: 4),
        Text("${val.toStringAsFixed(2)}U", style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}