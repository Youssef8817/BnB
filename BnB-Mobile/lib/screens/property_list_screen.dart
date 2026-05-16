import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/widgets/property_card.dart';
import 'package:b_and_b/widgets/filter_chips_row.dart';

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

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

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
          backgroundColor: const Color(0xFF93000A),
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
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Purple glow — top-right ───────────────────────────────
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
          // ── Blue glow — bottom-left ───────────────────────────────
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

          // ── Content ───────────────────────────────────────────────
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
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: _primary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Properties',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${_filteredProperties.length} listing${_filteredProperties.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: _onSurfaceVariant.withValues(alpha: 0.7),
                              ),
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x44A078FF),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Color(0xFF3C0091), size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFFDAE2FD)),
                      onChanged: (v) {
                        _searchQuery = v;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by title, city or location…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: _onSurfaceVariant.withValues(alpha: 0.40),
                        ),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: _primary.withValues(alpha: 0.7), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _applyFilters();
                                },
                                child: Icon(Icons.close_rounded,
                                    color: _onSurfaceVariant
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

                // City filter chips
                FilterChipsRow(
                  options: const [
                    'All',
                    'Cairo',
                    'Giza',
                    'Alexandria',
                    'Luxor',
                    'Aswan',
                  ],
                  selected: _selectedCity ?? 'All',
                  onSelected: (value) {
                    setState(
                        () => _selectedCity = value == 'All' ? null : value);
                    _load(city: _selectedCity);
                  },
                ),

                const SizedBox(height: 12),

                // List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _primary))
                      : _filteredProperties.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: _primary,
                              backgroundColor: const Color(0xFF171F33),
                              onRefresh: () => _load(city: _selectedCity),
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 0, 20, 32),
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
              color: Colors.white.withValues(alpha: 0.05),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.home_work_outlined,
                color: _primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Properties Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filters.',
            style: TextStyle(fontSize: 14, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
