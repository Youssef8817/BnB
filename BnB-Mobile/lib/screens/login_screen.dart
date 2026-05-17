import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey           = GlobalKey<FormState>();
  final _emailController   = TextEditingController();
  final _passwordController= TextEditingController();
  bool _isLoading          = false;
  bool _obscurePassword    = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await ApiService.login(
          _emailController.text.trim(),
          _passwordController.text,
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
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
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
                        // ── Top logo ──────────────────────────────────────
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C5CFC).withValues(alpha: 0.4),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo/Logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Headings ──────────────────────────────────────
                        ShaderMask(
                          shaderCallback: (r) => const LinearGradient(
                            colors: [Color(0xFFB69EFF), Color(0xFF4FC3F7)],
                          ).createShader(r),
                          child: const Text(
                            'Welcome\nBack.',
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
                          'Sign in to your concierge dashboard.',
                          textAlign: TextAlign.center,
                          style: AppText.bodySmall,
                        ),
                        const SizedBox(height: 36),

                        // ── Glass form card ───────────────────────────────
                        GlassBox(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 28),
                              GradientButton(
                                label: 'Sign In',
                                icon: Icons.arrow_forward_rounded,
                                onTap: _login,
                                isLoading: _isLoading,
                                height: 56,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Register link ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppText.bodySmall,
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text(
                                'Create one',
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
