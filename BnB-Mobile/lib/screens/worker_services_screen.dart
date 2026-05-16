import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/repositories/service_repository.dart';
import 'package:b_and_b/widgets/filter_chips_row.dart';
import 'package:b_and_b/widgets/service_card.dart';
import 'package:flutter/material.dart';

class WorkerServicesScreen extends StatefulWidget {
  const WorkerServicesScreen({super.key});

  @override
  _WorkerServicesScreenState createState() => _WorkerServicesScreenState();
}

class _WorkerServicesScreenState extends State<WorkerServicesScreen> {
  final _repo = ServiceRepository();

  List<WorkerService> _services     = [];
  bool    _isLoading    = true;
  String? _selectedType;

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

  static const _typeOptions = [
    'All', 'plumbing', 'painting', 'tiling',
    'electrical', 'carpentry', 'finishing',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? type}) async {
    setState(() => _isLoading = true);
    try {
      final services = await _repo.getAll(type: type);
      setState(() {
        _services  = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF93000A),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Purple glow — top-right ─────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.95, -0.95),
                  radius: 0.9,
                  colors: [Color(0x556D3BD7), Color(0x000B1326)],
                ),
              ),
            ),
          ),
          // ── Blue glow — bottom-left ─────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.95, 0.95),
                  radius: 0.7,
                  colors: [Color(0x3300A2E6), Color(0x000B1326)],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _primary,
                              size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Services',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${_services.length} available',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    _onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Type filter chips
                FilterChipsRow(
                  options: _typeOptions,
                  selected: _selectedType ?? 'All',
                  onSelected: (value) {
                    setState(() =>
                        _selectedType = value == 'All' ? null : value);
                    _load(type: _selectedType);
                  },
                ),

                const SizedBox(height: 12),

                // List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primary))
                      : _services.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: _primary,
                              backgroundColor: const Color(0xFF171F33),
                              onRefresh: () => _load(type: _selectedType),
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 0, 20, 32),
                                itemCount: _services.length,
                                itemBuilder: (_, i) =>
                                    ServiceCard(service: _services[i]),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.handyman_outlined,
                color: _primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different category filter.',
            style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
