import 'package:flutter/material.dart';
import 'dart:async';
import '../services/nexus_api.dart';
import '../models/vault_transaction.dart';
// FIX 1: Using the universal gateway to prevent CI/Desktop build failure
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

class _NexusDashboardState extends State<NexusDashboard> with WidgetsBindingObserver {
  final TextEditingController _amountController = TextEditingController(text: "100.00");
  final ScrollController _scrollController = ScrollController();
  
  // FIX 2: Added Cursor and Pagination state
  List<VaultTransaction> _transactions = [];
  Map<String, dynamic>? _cursor;
  bool _hasMore = true;
  
  double _creatorTotal = 0.0;
  double _poolTotal = 0.0;
  bool _isLoading = true;
  bool _isExecuting = false;
  bool _retryScheduled = false;
  bool _isSyncing = false;
  String _statusMessage = "BOOTING_CORE";

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncSovereignState();
    }
  }

  // FIX 3: Refactored to handle CursorPage return type
  Future<void> _syncSovereignState() async {
    if (!mounted || _isSyncing) return;
    setState(() {
      _isSyncing = true;
      _isLoading = true;
      _statusMessage = "SYNCING_WITH_BRAIN";
    });

    try {
      final results = await Future.wait([
        NexusApi.fetchVaultSummary(),
        NexusApi.fetchTransactions(cursor: null),
      ]).timeout(const Duration(seconds: 15));

      final summary = results[0] as Map<String, dynamic>;
      final page = results[1] as CursorPage;

      if (!mounted) return;

      setState(() {
        // Map page items correctly using the model
        _transactions = page.items
            .map((e) => VaultTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // Save cursor state for future infinite scrolling
        _cursor = page.nextCursor;
        _hasMore = page.nextCursor != null;

        _creatorTotal = (summary['creator_total'] as num? ?? 0).toDouble();
        _poolTotal = (summary['pool_total'] as num? ?? 0).toDouble();
        
        _statusMessage = "SYSTEM_STABLE";
        _retryScheduled = false;
      });
    } catch (_) {
      if (mounted) setState(() => _statusMessage = "SYNC_FAILURE_RETRYING");
      if (!_retryScheduled) {
        _retryScheduled = true;
        Future.delayed(const Duration(seconds: 5), () {
          _retryScheduled = false;
          if (mounted) _syncSovereignState();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _executeSequence() async {
    final amount = double.tryParse(_amountController.text);
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
      await NexusApi.executeSplit(amount);
      if (mounted) setState(() => _statusMessage = "BLOCK_COMMITTED");
      await Future.delayed(const Duration(milliseconds: 1200));
      await _syncSovereignState();
    } catch (_) {
      if (mounted) setState(() => _statusMessage = "SENTRY_REJECTED");
    } finally {
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () => setState(() => _isExecuting = false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.05,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
              itemBuilder: (context, index) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.5))),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildVaultCard(),
                        const SizedBox(height: 24),
                        _buildControlPanel(),
                        const SizedBox(height: 30),
                        _buildLedger(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildConsole(),
              ],
            ),
          ),
        ],
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
            const Text("NEXUS_PROTOCOL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
            Text("OPERATOR_ID: ${TelegramBridge.userId}", style: const TextStyle(color: Colors.white24, fontSize: 9, fontFamily: 'monospace')),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: _primary.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)),
          child: Text(widget.telegramReady ? "● SOVEREIGN" : "○ LOCAL", style: const TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold)),
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
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.05), blurRadius: 30)],
      ),
      child: Column(
        children: [
          const Text("TOTAL_VAULT_LIQUIDITY", style: TextStyle(color: Colors.white38, fontSize: 10)),
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
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: _terminal, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            decoration: const InputDecoration(border: InputBorder.none, prefixText: "SPLIT_AMT: ", hintText: "0.00", prefixStyle: TextStyle(color: Colors.white24, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isExecuting || _isLoading ? null : _executeSequence,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isExecuting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("EXECUTE_PROTOCOL_SPLIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildLedger() {
    if (_transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("NO_RECORDS_FOUND", style: TextStyle(color: Colors.white10, fontFamily: 'monospace')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SOVEREIGN_LEDGER", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ..._transactions.map(_buildTxRow),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.type.toUpperCase(), style: TextStyle(color: tx.type == "split" ? _terminal : _primary, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(tx.formattedTime, style: const TextStyle(color: Colors.white12, fontSize: 8)),
          ]),
          Text("+${tx.amount.toStringAsFixed(2)} U", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildConsole() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: _border))),
      child: Row(
        children: [
          const Text("> ", style: TextStyle(color: _terminal, fontWeight: FontWeight.bold)),
          Expanded(child: Text(_statusMessage, style: TextStyle(color: _statusMessage.contains("FAILURE") ? _error : _terminal.withOpacity(0.6), fontFamily: 'monospace', fontSize: 10), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _vaultStat(String label, double val, Color color) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9)),
      const SizedBox(height: 4),
      Text("${val.toStringAsFixed(2)}U", style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    ]);
  }
}