import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────────
  static const bg          = Color(0xFF060B18);
  static const surface     = Color(0xFF0D1424);
  static const surfaceHigh = Color(0xFF131C30);
  static const card        = Color(0xFF111827);

  // ── Accent: Electric Violet ───────────────────────────────────────────────
  static const accent      = Color(0xFFB69EFF);
  static const accentDeep  = Color(0xFF7C5CFC);
  static const accentGlow  = Color(0x33B69EFF);
  static const accentSoft  = Color(0x15B69EFF);

  // ── Secondary: Cyan-Blue ──────────────────────────────────────────────────
  static const cyan        = Color(0xFF4FC3F7);
  static const cyanGlow    = Color(0x334FC3F7);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFFB0BDDA);
  static const textMuted     = Color(0xFF6B7A9F);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error   = Color(0xFFFF5370);
  static const errorBg = Color(0xFF2D0A12);

  // ── Borders / Dividers ────────────────────────────────────────────────────
  static const border     = Color(0x1AFFFFFF);
  static const borderSoft = Color(0x0DFFFFFF);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const gradientPrimary = LinearGradient(
    colors: [accentDeep, Color(0xFF4FC3F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientCard = LinearGradient(
    colors: [Color(0xFF1A2140), Color(0xFF0D1424)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow presets
  static const glowPurple = RadialGradient(
    center: Alignment(0.95, -0.95),
    radius: 1.1,
    colors: [Color(0x40704EFF), Color(0x000B1326)],
  );

  static const glowCyan = RadialGradient(
    center: Alignment(-0.95, 0.95),
    radius: 0.9,
    colors: [Color(0x284FC3F7), Color(0x000B1326)],
  );
}

abstract final class AppText {
  static const display = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -2.0,
    height: 1.05,
  );

  static const h1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.2,
    height: 1.1,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  static const price = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.accent,
    letterSpacing: -0.8,
    height: 1.0,
  );
}

// ── Shared widget builders ───────────────────────────────────────────────────

class GlassBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassBox({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    this.color,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.09),
          width: 1,
        ),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.65 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C5CFC), Color(0xFF4FC3F7)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x507C5CFC),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class BackButton2 extends StatelessWidget {
  final VoidCallback? onTap;
  const BackButton2({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.accent,
          size: 16,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  static (Color, String) _resolve(String s) {
    return switch (s.toLowerCase()) {
      'available'  => (AppColors.success, 'Available'),
      'pending'    => (AppColors.warning, 'Pending'),
      'sold'       => (AppColors.textMuted, 'Sold'),
      'accepted'   => (AppColors.cyan, 'Accepted'),
      'completed'  => (AppColors.success, 'Completed'),
      'cancelled'  => (AppColors.textMuted, 'Cancelled'),
      _            => (AppColors.textMuted, s),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.glowPurple,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.glowCyan,
            ),
          ),
        ),
      ],
    );
  }
}

class PremiumInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final int maxLines;

  const PremiumInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppText.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.accent.withValues(alpha: 0.6))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accentDeep, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      size: 18,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
