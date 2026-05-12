import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/repositories/service_repository.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/widgets/property_card.dart';
import 'package:b_and_b/widgets/service_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  List<WorkerService> _services = [];
  bool _isLoading = true;
  String? _userRole;

  final _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int count) {
    if (count <= 1) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % count;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final propertyRepository = PropertyRepository();
      final serviceRepository = ServiceRepository();
      final results = await Future.wait([
        ApiService.getMe(),
        propertyRepository.getAll(),
        serviceRepository.getAll(),
      ]);
      setState(() {
        _userRole = ((results[0] as dynamic).role as String?) ?? '';
        _properties = results[1] as List<Property>;
        _services = results[2] as List<WorkerService>;
        _isLoading = false;
      });
      final featured = _properties.take(5).toList();
      _startAutoScroll(featured.length);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B&B'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Requests',
            onPressed: () => context.push('/my-requests'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _userRole == 'worker'
                  ? _buildWorkerView()
                  : _buildUserView(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/properties/add'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkerView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          title: 'Properties',
          onSeeAll: () => context.push('/my-properties'),
        ),
        ..._properties.map((p) => PropertyCard(property: p)),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Services',
          onSeeAll: () => context.push('/services'),
        ),
        ..._services.map((s) => ServiceCard(service: s)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.push('/worker-dashboard'),
          icon: const Icon(Icons.dashboard),
          label: const Text('Worker Dashboard'),
        ),
      ],
    );
  }

  Widget _buildUserView() {
    final featured = _properties.take(5).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(
          title: 'Featured Properties',
          onSeeAll: () => context.push('/properties/list'),
        ),
        const SizedBox(height: 8),
        if (featured.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No properties yet.')),
          )
        else
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: featured.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: PropertyCard(property: featured[i]),
              ),
            ),
          ),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Available Services',
          onSeeAll: () => context.push('/services'),
        ),
        const SizedBox(height: 8),
        if (_services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No services yet.')),
          )
        else
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _services.length,
              itemBuilder: (_, i) => SizedBox(
                width: 160,
                child: ServiceCard(service: _services[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}
