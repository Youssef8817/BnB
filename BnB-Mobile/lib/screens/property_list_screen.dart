import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:b_and_b/widgets/filter_chips_row.dart';
import 'package:b_and_b/widgets/property_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final _repo             = PropertyRepository();
  final _searchController = TextEditingController();

  List<Property> _allProperties      = [];
  List<Property> _filteredProperties = [];
  bool    _isLoading    = true;
  String? _selectedCity;
  String  _searchQuery  = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String? city}) async {
    setState(() => _isLoading = true);
    try {
      final props = await _repo.getAll(city: city);
      setState(() {
        _allProperties = props;
        _isLoading     = false;
      });
      _applyFilters();
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

  void _applyFilters() {
    final q = _searchQuery.toLowerCase();
    setState(() {
      _filteredProperties = _allProperties.where((p) {
        return q.isEmpty ||
            p.title.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q);
      }).toList();
    });
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
                            Text('Properties', style: AppText.h3),
                            Text(
                              '${_filteredProperties.length} listing${_filteredProperties.length == 1 ? '' : 's'}',
                              style: AppText.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Add button
                      GestureDetector(
                        onTap: () => context.push('/properties/add'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.gradientPrimary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentDeep.withValues(alpha: 0.40),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassBox(
                    radius: 14,
                    padding: EdgeInsets.zero,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary),
                      onChanged: (v) {
                        _searchQuery = v;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by title, city or location…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted.withValues(alpha: 0.40),
                        ),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppColors.accent.withValues(alpha: 0.7),
                            size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _applyFilters();
                                },
                                child: Icon(Icons.close_rounded,
                                    color: AppColors.textMuted
                                        .withValues(alpha: 0.5),
                                    size: 18),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                FilterChipsRow(
                  options: const [
                    'All', 'Cairo', 'Giza', 'Alexandria', 'Luxor', 'Aswan',
                  ],
                  selected: _selectedCity ?? 'All',
                  onSelected: (value) {
                    setState(() =>
                        _selectedCity = value == 'All' ? null : value);
                    _load(city: _selectedCity);
                  },
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : _filteredProperties.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: AppColors.accent,
                              backgroundColor: AppColors.surface,
                              onRefresh: () => _load(city: _selectedCity),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 32),
                                itemCount: _filteredProperties.length,
                                itemBuilder: (_, i) => PropertyCard(
                                    property: _filteredProperties[i]),
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
            child: const Icon(Icons.home_work_outlined,
                color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No Properties Found', style: AppText.h4),
          const SizedBox(height: 6),
          Text('Try adjusting your search or filters.',
              style: AppText.bodySmall),
        ],
      ),
    );
  }
}
