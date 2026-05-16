import 'dart:async';

import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/repositories/service_repository.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
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

  final _pageController = PageController(viewportFraction: 0.86);
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  int _navIndex    = 0;

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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % count;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
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
            backgroundColor: AppColors.errorBg,
          ),
        );
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

          Column(
            children: [
              _TopBar(
                userName: _userName,
                onProfileTap: () => context.push('/profile'),
              ),
              Expanded(
                child: _isLoading
                    ? _buildSkeleton()
                    : RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.surfaceHigh,
                        onRefresh: _loadData,
                        child: _userRole == 'worker'
                            ? _buildWorkerView()
                            : _buildUserView(),
                      ),
              ),
            ],
          ),

          // FAB
          Positioned(
            right: 20,
            bottom: 100,
            child: GestureDetector(
              onTap: () => context.push('/properties/add'),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AppColors.gradientPrimary,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x607C5CFC),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),

          // Bottom nav
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _BottomNav(
              index: _navIndex,
              onTap: (i) {
                setState(() => _navIndex = i);
                if (i == 1) context.push('/properties/list');
                if (i == 2) context.push('/my-requests');
                if (i == 3) context.push('/profile');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        _SkeletonBox(height: 32, width: 200, radius: 8),
        const SizedBox(height: 8),
        _SkeletonBox(height: 20, width: 140, radius: 6),
        const SizedBox(height: 24),
        _SkeletonBox(height: 52, radius: 16),
        const SizedBox(height: 28),
        _SkeletonBox(height: 20, width: 160, radius: 6),
        const SizedBox(height: 16),
        _SkeletonBox(height: 300, radius: 24),
        const SizedBox(height: 28),
        _SkeletonBox(height: 20, width: 160, radius: 6),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 180, radius: 20)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonBox(height: 180, radius: 20)),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkerView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
      children: [
        _HeroHeading(
          name: _userName,
          subtitle: 'Manage your listings & services',
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'My Properties',
          subtitle: 'Active listings',
          actionLabel: 'SEE ALL',
          onAction: () => context.push('/my-properties'),
        ),
        const SizedBox(height: 12),
        if (_properties.isEmpty)
          _EmptyInline(icon: Icons.home_work_outlined, label: 'No properties yet')
        else
          ..._properties.take(3).map((p) => _PropertyListTile(property: p)),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'My Services',
          subtitle: 'Offered services',
          actionLabel: 'SEE ALL',
          onAction: () => context.push('/services'),
        ),
        const SizedBox(height: 12),
        if (_services.isEmpty)
          _EmptyInline(icon: Icons.handyman_outlined, label: 'No services yet')
        else
          ..._services.take(3).map((s) => _ServiceListTile(service: s)),
        const SizedBox(height: 20),
        _DashboardButton(
          icon: Icons.dashboard_rounded,
          label: 'Open Worker Dashboard',
          onTap: () => context.push('/worker-dashboard'),
        ),
      ],
    );
  }

  Widget _buildUserView() {
    final featured = _properties.take(5).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeading(name: _userName, subtitle: null),
              const SizedBox(height: 20),
              _SearchBar(onTap: () => context.push('/properties/list')),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(
            title: 'Featured Properties',
            subtitle: 'Curated premium listings',
            actionLabel: 'VIEW ALL',
            onAction: () => context.push('/properties/list'),
          ),
        ),
        const SizedBox(height: 16),
        if (featured.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: _EmptyInline(
              icon: Icons.home_work_outlined,
              label: 'No properties yet',
            ),
          )
        else
          SizedBox(
            height: 310,
            child: PageView.builder(
              controller: _pageController,
              itemCount: featured.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _FeaturedCard(property: featured[i]),
              ),
            ),
          ),

        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(
            title: 'Available Services',
            subtitle: 'Expert help at your door',
            actionLabel: 'EXPLORE',
            onAction: () => context.push('/services'),
          ),
        ),
        const SizedBox(height: 16),
        if (_services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: _EmptyInline(
              icon: Icons.handyman_outlined,
              label: 'No services yet',
            ),
          )
        else
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _services.length,
              itemBuilder: (_, i) => _ServiceMiniCard(service: _services[i]),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onProfileTap;
  const _TopBar({required this.userName, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Color(0xFFB69EFF), Color(0xFF4FC3F7)],
              ).createShader(r),
              child: const Text(
                'B&B',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.gradientPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentDeep.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
  final String name;
  final String? subtitle;
  const _HeroHeading({required this.name, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
              height: 1.2,
            ),
            children: [
              if (name.isNotEmpty)
                TextSpan(
                  text: 'Hello, ${name.split(' ').first}\n',
                ),
              const TextSpan(
                text: 'Find Your ',
              ),
              const TextSpan(
                text: 'Sanctuary',
                style: TextStyle(
                  color: AppColors.accent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: AppText.bodySmall),
        ],
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Text(
              'Search properties, services…',
              style: AppText.bodySmall.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentGlow),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
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
              Text(title, style: AppText.h4),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.bodySmall),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Featured property card ────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final Property property;
  const _FeaturedCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          property.images.isNotEmpty
              ? Image.network(
                  property.images.first.fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xEE060B18)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
          ),

          // Content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (property.city.isNotEmpty)
                        _Tag(label: property.city, isPrimary: true),
                      const SizedBox(width: 6),
                      _Tag(label: '${property.rooms} Rooms'),
                      if (property.areaMq > 0) ...[
                        const SizedBox(width: 6),
                        _Tag(label: '${property.areaMq.toStringAsFixed(0)}m²'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
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

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientCard,
        ),
        child: const Center(
          child: Icon(Icons.home_work_outlined,
              color: Color(0x33B69EFF), size: 64),
        ),
      );
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
            ? AppColors.accentSoft
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPrimary
              ? AppColors.accentGlow
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isPrimary ? AppColors.accent : AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Service mini card (horizontal scroll) ─────────────────────────────────────

class _ServiceMiniCard extends StatelessWidget {
  final WorkerService service;
  const _ServiceMiniCard({required this.service});

  static const _icons = {
    'plumbing':   Icons.plumbing,
    'painting':   Icons.format_paint,
    'tiling':     Icons.grid_on,
    'electrical': Icons.electrical_services,
    'carpentry':  Icons.carpenter,
    'finishing':  Icons.home_repair_service,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[service.type.toLowerCase()] ?? Icons.handyman_outlined;
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: AppColors.gradientPrimary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentDeep.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            service.type,
            style: AppText.h4.copyWith(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodySmall.copyWith(fontSize: 11),
          ),
          const Spacer(),
          Text(
            '\$${service.pricePerUnit}/${service.unit}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Worker list tiles ─────────────────────────────────────────────────────────

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
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: property.images.isNotEmpty
                  ? Image.network(property.images.first.fullUrl,
                      fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                          gradient: AppColors.gradientCard),
                      child: const Icon(Icons.home_outlined,
                          color: Color(0x55B69EFF), size: 26),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title,
                    style: AppText.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
                if (property.city.isNotEmpty)
                  Text(property.city, style: AppText.bodySmall),
              ],
            ),
          ),
          Text(
            '\$${property.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

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
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.gradientPrimary,
            ),
            child: const Icon(Icons.handyman_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.type,
                    style: AppText.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
                Text('\$${service.pricePerUnit}/${service.unit}',
                    style: AppText.bodySmall.copyWith(
                        color: AppColors.accent, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: service.isAvailable
                  ? AppColors.success
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: AppColors.gradientPrimary,
          boxShadow: const [
            BoxShadow(
              color: Color(0x507C5CFC),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int index;
  final void Function(int) onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home',
              active: index == 0, onTap: () => onTap(0)),
          _NavItem(icon: Icons.search_rounded, label: 'Search',
              active: index == 1, onTap: () => onTap(1)),
          _NavItem(icon: Icons.receipt_long_outlined, label: 'Requests',
              active: index == 2, onTap: () => onTap(2)),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile',
              active: index == 3, onTap: () => onTap(3)),
        ],
      ),
    );
  }
}

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
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
            horizontal: active ? 20 : 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: active ? AppColors.gradientPrimary : null,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.accentDeep.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 20,
                color: active ? Colors.white : AppColors.textMuted),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Skeleton & empty helpers ──────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  const _SkeletonBox(
      {required this.height, this.width, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyInline({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: AppText.bodySmall),
        ],
      ),
    );
  }
}
