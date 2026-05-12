import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/widgets/property_card.dart';
import 'package:b_and_b/widgets/empty_state.dart';
import 'package:b_and_b/widgets/filter_chips_row.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({Key? key}) : super(key: key);

  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyRepository _propertyRepository = PropertyRepository();
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = true;
  String? _selectedCity;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties({String? city}) async {
    setState(() => _isLoading = true);
    try {
      final properties = await _propertyRepository.getAll(city: city);
      setState(() {
        _allProperties = properties;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _applyFilters() {
    final q = _searchQuery.toLowerCase();
    setState(() {
      _filteredProperties = _allProperties.where((p) {
        final matchesSearch = q.isEmpty ||
            p.title.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q);
        return matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/properties/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title, city or location...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          const SizedBox(height: 8),
          FilterChipsRow(
            options: ['All', 'Cairo', 'Giza', 'Alexandria', 'Luxor', 'Aswan'],
            selected: _selectedCity == null ? 'All' : _selectedCity,
            onSelected: (value) {
              setState(() => _selectedCity = value == 'All' ? null : value);
              _loadProperties(city: _selectedCity);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProperties.isEmpty
                    ? const EmptyState(
                        message: 'No properties found',
                        icon: Icons.list_alt,
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadProperties(city: _selectedCity),
                        child: ListView.builder(
                          itemCount: _filteredProperties.length,
                          itemBuilder: (context, index) {
                            return PropertyCard(
                                property: _filteredProperties[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}