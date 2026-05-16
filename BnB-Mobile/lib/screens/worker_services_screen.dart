import 'package:b_and_b/theme/app_theme.dart';
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

  List<WorkerService> _services    = [];
  bool    _isLoading   = true;
  String? _selectedType;

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
          backgroundColor: AppColors.errorBg,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      BackButton2(onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Services', style: AppText.h3),
                            Text(
                              '${_services.length} available',
                              style: AppText.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                FilterChipsRow(
                  options: _typeOptions,
                  selected: _selectedType ?? 'All',
                  onSelected: (value) {
                    setState(
                        () => _selectedType = value == 'All' ? null : value);
                    _load(type: _selectedType);
                  },
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : _services.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: AppColors.accent,
                              backgroundColor: AppColors.surface,
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
              color: AppColors.accentSoft,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.handyman_outlined,
                color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No Services Found', style: AppText.h4),
          const SizedBox(height: 6),
          Text('Try a different category filter.', style: AppText.bodySmall),
        ],
      ),
    );
  }
}
