import 'dart:async';

import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/repositories/service_repository.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property>      _properties = [];
  List<WorkerService> _services   = [];
  bool    _isLoading = true;
  String? _userRole;
  String  _userName = '';

  final _pageController = PageController(viewportFraction: 0.88);
  Timer? _autoScrollTimer;
  int    _currentPage = 0;
  int    _navIndex    = 0;

  // ── Design tokens ────────────────────────────────────────────────
  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

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
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getMe(),
        PropertyRepository().getAll(),
        ServiceRepository().getAll(),
      ]);
      setState(() {
        final me  = results[0] as dynamic;
        _userRole = (me.role as String?) ?? '';
        _userName = (me.name as String?) ?? '';
        _properties = results[1] as List<Property>;
        _services   = results[2] as List<WorkerService>;
        _isLoading  = false;
      });
      _startAutoScroll(_properties.take(5).length);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFF93000A),
          ),
        );
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
          // ── Background glows ──────────────────────────────────────
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

          // ── Main content ─────────────────────────────────────────
          Column(
            children: [
              _TopBar(
                userName: _userName,
                onProfileTap: () => context.push('/profile'),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primary))
                    : RefreshIndicator(
                        color: _primary,
                        backgroundColor: const Color(0xFF171F33),
                        onRefresh: _loadData,
                        child: _userRole == 'worker'
                            ? _buildWorkerView()
                            : _buildUserView(),
                      ),
              ),
            ],
          ),

          // ── Gradient FAB ─────────────────────────────────────────
          Positioned(
            right: 20,
            bottom: 96,
            child: GestureDetector(
              onTap: () => context.push('/properties/add'),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x806D3BD7),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          ),

          // ── Bottom nav bar ────────────────────────────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.92,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF171F33).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D000000),
                      blurRadius: 40,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      active: _navIndex == 0,
                      onTap: () => setState(() => _navIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.search_rounded,
                      label: 'Search',
                      active: _navIndex == 1,
                      onTap: () {
                        setState(() => _navIndex = 1);
                        context.push('/properties/list');
                      },
                    ),
                    _NavItem(
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Requests',
                      active: _navIndex == 2,
                      onTap: () {
                        setState(() => _navIndex = 2);
                        context.push('/my-requests');
                      },
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      active: _navIndex == 3,
                      onTap: () {
                        setState(() => _navIndex = 3);
                        context.push('/profile');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Worker view ───────────────────────────────────────────────────

  Widget _buildWorkerView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      children: [
        _HeroHeading(subtitle: 'Manage your listings & services'),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'Properties',
          subtitle: 'Your active listings',
          actionLabel: 'SEE ALL',
          onAction: () => context.push('/my-properties'),
        ),
        const SizedBox(height: 12),
        ..._properties.map((p) => _PropertyListTile(property: p)),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'Services',
          subtitle: 'Your offered services',
          actionLabel: 'SEE ALL',
          onAction: () => context.push('/services'),
        ),
        const SizedBox(height: 12),
        ..._services.map((s) => _ServiceListTile(service: s)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.push('/worker-dashboard'),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.dashboard_outlined, color: _primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Worker Dashboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── User view ─────────────────────────────────────────────────────

  Widget _buildUserView() {
    final featured = _properties.take(5).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Hero + search
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeading(subtitle: null),
              const SizedBox(height: 20),
              // Glass search bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: _primary.withValues(alpha: 0.8), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Search by destination or service',
                      style: TextStyle(
                        fontSize: 14,
                        color: _onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Featured Properties
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(
            title: 'Featured Properties',
            subtitle: 'Curated luxury listings',
            actionLabel: 'VIEW ALL',
            onAction: () => context.push('/properties/list'),
          ),
        ),
        const SizedBox(height: 16),
        if (featured.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No properties yet.',
                  style: TextStyle(color: _onSurfaceVariant)),
            ),
          )
        else
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _pageController,
              itemCount: featured.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _FeaturedPropertyCard(property: featured[i]),
              ),
            ),
          ),

        const SizedBox(height: 32),

        // Available Services
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(
            title: 'Available Services',
            subtitle: 'Bespoke assistance at your door',
            actionLabel: 'EXPLORE ALL',
            onAction: () => context.push('/services'),
          ),
        ),
        const SizedBox(height: 16),
        if (_services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('No services yet.',
                  style: TextStyle(color: _onSurfaceVariant)),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _services.length,
              itemBuilder: (_, i) => _ServiceCard(service: _services[i]),
            ),
          ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onProfileTap;
  const _TopBar({required this.userName, required this.onProfileTap});

  static const Color _primary = Color(0xFFD0BCFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1326).withValues(alpha: 0.10),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Text(
              'B&B',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                  ),
                  border: Border.all(
                      color: _primary.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C0091),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero heading ──────────────────────────────────────────────────────────────

class _HeroHeading extends StatelessWidget {
  final String? subtitle;
  const _HeroHeading({this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFFDAE2FD),
              letterSpacing: -0.8,
              height: 1.15,
            ),
            children: [
              TextSpan(text: 'Find Your\n'),
              TextSpan(
                text: 'Sanctuary',
                style: TextStyle(
                  color: Color(0xFFD0BCFF),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCBC3D7),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDAE2FD),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFCBC3D7).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD0BCFF),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Featured property card ────────────────────────────────────────────────────

class _FeaturedPropertyCard extends StatelessWidget {
  final Property property;
  const _FeaturedPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or gradient placeholder
          property.images.isNotEmpty
              ? Image.network(
                  property.images.first.fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),

          // Bottom gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0B1326)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Row(
                    children: [
                      if (property.city.isNotEmpty)
                        _Tag(label: property.city, isPrimary: true),
                      const SizedBox(width: 6),
                      _Tag(label: '${property.rooms} Rooms'),
                      const SizedBox(width: 6),
                      if (property.areaMq > 0)
                        _Tag(label: '${property.areaMq.toStringAsFixed(0)}m²'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDAE2FD),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD0BCFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1040), Color(0xFF0B1326)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.home_work_outlined,
            color: Color(0x33D0BCFF), size: 64),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool isPrimary;
  const _Tag({required this.label, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFD0BCFF).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isPrimary
              ? const Color(0xFFD0BCFF)
              : const Color(0xFFDAE2FD),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Service card (horizontal scroll) ─────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final WorkerService service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66A078FF),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.handyman_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            service.type.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDAE2FD),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFCBC3D7).withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${service.pricePerUnit}/${service.unit}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD0BCFF),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.06),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: const Text(
                  'Request',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDAE2FD),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Property list tile (worker view) ─────────────────────────────────────────

class _PropertyListTile extends StatelessWidget {
  final Property property;
  const _PropertyListTile({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFF1A1040),
              child: property.images.isNotEmpty
                  ? Image.network(property.images.first.fullUrl, fit: BoxFit.cover)
                  : const Icon(Icons.home_outlined,
                      color: Color(0x66D0BCFF), size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDAE2FD),
                  ),
                ),
                if (property.city.isNotEmpty)
                  Text(
                    property.city,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFFCBC3D7).withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${property.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD0BCFF),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service list tile (worker view) ──────────────────────────────────────────

class _ServiceListTile extends StatelessWidget {
  final WorkerService service;
  const _ServiceListTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
              ),
            ),
            child: const Icon(Icons.handyman_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDAE2FD),
                  ),
                ),
                Text(
                  '\$${service.pricePerUnit}/${service.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD0BCFF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: service.isAvailable
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF958EA0),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 18 : 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFD0BCFF), Color(0xFFD0BCFF)],
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? const Color(0xFF3C0091) : const Color(0xFFCBC3D7),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active
                    ? const Color(0xFF3C0091)
                    : const Color(0xFFCBC3D7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
