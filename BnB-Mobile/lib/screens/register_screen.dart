import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey            = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController    = TextEditingController();
  String _selectedRole      = 'user';
  bool _isLoading           = false;
  bool _obscurePassword     = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeIn  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _phoneController.text.trim(),
          _selectedRole,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, response['token']);
        await prefs.setString(Constants.userKey, json.encode(response['user']));
        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.errorBg,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: FadeTransition(
                opacity: _fadeIn,
                child: AnimatedBuilder(
                  animation: _slideUp,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, 30 * (1 - _slideUp.value)),
                    child: child,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Back ─────────────────────────────────────────
                        Align(
                          alignment: Alignment.centerLeft,
                          child: BackButton2(onTap: () => context.pop()),
                        ),
                        const SizedBox(height: 24),

                        // ── Headings ──────────────────────────────────────
                        ShaderMask(
                          shaderCallback: (r) => const LinearGradient(
                            colors: [Color(0xFFB69EFF), Color(0xFF4FC3F7)],
                          ).createShader(r),
                          child: const Text(
                            'Create\nAccount.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2.0,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Join the premium concierge platform.',
                          textAlign: TextAlign.center,
                          style: AppText.bodySmall,
                        ),
                        const SizedBox(height: 28),

                        // ── Glass form card ───────────────────────────────
                        GlassBox(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PremiumInputField(
                                controller: _nameController,
                                hintText: 'Your full name',
                                label: 'Full Name',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              PremiumInputField(
                                controller: _emailController,
                                hintText: 'your@email.com',
                                label: 'Email Address',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.alternate_email_rounded,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter your email';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              PremiumInputField(
                                controller: _passwordController,
                                hintText: '••••••••••',
                                label: 'Password',
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                onSuffixTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter your password';
                                  if (v.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              PremiumInputField(
                                controller: _phoneController,
                                hintText: '+1 234 567 8900',
                                label: 'Phone Number',
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Enter your phone'
                                    : null,
                              ),
                              const SizedBox(height: 18),

                              // Role selector
                              Text(
                                'Account Type',
                                style: AppText.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _RoleSelector(
                                selected: _selectedRole,
                                onChanged: (v) => setState(() => _selectedRole = v),
                              ),

                              const SizedBox(height: 28),
                              GradientButton(
                                label: 'Create Account',
                                icon: Icons.arrow_forward_rounded,
                                onTap: _register,
                                isLoading: _isLoading,
                                height: 56,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Login link ────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: AppText.bodySmall,
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Sign in',
                                style: AppText.bodySmall.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

// ── Role selector ─────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;
  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleChip(
          label: 'User',
          icon: Icons.person_rounded,
          value: 'user',
          selected: selected == 'user',
          onTap: () => onChanged('user'),
        ),
        const SizedBox(width: 12),
        _RoleChip(
          label: 'Worker',
          icon: Icons.handyman_rounded,
          value: 'worker',
          selected: selected == 'worker',
          onTap: () => onChanged('worker'),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF7C5CFC), Color(0xFF4FC3F7)],
                  )
                : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.10),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C5CFC).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
