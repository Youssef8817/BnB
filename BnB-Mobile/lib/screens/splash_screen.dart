import 'dart:math' as math;

import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _orbitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _progress;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );
    _textSlide = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );
    _progress = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.4, 0.90, curve: Curves.easeInOut),
    );
    _footerFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),

          // Orbiting ring decoration
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbitCtrl,
              builder: (_, __) {
                return CustomPaint(
                  painter: _OrbitPainter(progress: _orbitCtrl.value),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _LogoBadge(),
                  ),
                ),

                const SizedBox(height: 32),

                // Brand name
                FadeTransition(
                  opacity: _textFade,
                  child: AnimatedBuilder(
                    animation: _textSlide,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, 20 * (1 - _textSlide.value)),
                      child: child,
                    ),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (r) => const LinearGradient(
                            colors: [Color(0xFFB69EFF), Color(0xFF4FC3F7)],
                          ).createShader(r),
                          child: const Text(
                            'B&B',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -3.0,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'REAL ESTATE & HOME SERVICES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted.withValues(alpha: 0.8),
                            letterSpacing: 4.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // Progress bar
                AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => _ProgressBar(value: _progress.value),
                ),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _footerFade,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Text(
                    'PREMIUM LIFESTYLE CONCIERGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1445), Color(0xFF0D1424)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5CFC).withValues(alpha: 0.45),
            blurRadius: 60,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                radius: 0.8,
                colors: [Color(0x30B69EFF), Colors.transparent],
              ),
            ),
          ),
          const Icon(
            Icons.location_city_rounded,
            color: AppColors.accent,
            size: 72,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 220,
          height: 2.5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB69EFF), Color(0xFF4FC3F7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB69EFF).withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Loading your experience…',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  _OrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer orbit
    paint.color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.58, paint);

    // Inner orbit
    paint.color = Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.38, paint);

    // Orbiting dot on outer ring
    final angle1 = 2 * math.pi * progress;
    final dx1 = cx + size.width * 0.58 * math.cos(angle1);
    final dy1 = cy + size.width * 0.58 * math.sin(angle1);
    final dotPaint1 = Paint()
      ..color = const Color(0xFFB69EFF).withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(dx1, dy1), 5, dotPaint1);

    // Orbiting dot on inner ring (opposite direction)
    final angle2 = 2 * math.pi * (1 - progress) + math.pi / 3;
    final dx2 = cx + size.width * 0.38 * math.cos(angle2);
    final dy2 = cy + size.width * 0.38 * math.sin(angle2);
    final dotPaint2 = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(dx2, dy2), 3.5, dotPaint2);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.progress != progress;
}
