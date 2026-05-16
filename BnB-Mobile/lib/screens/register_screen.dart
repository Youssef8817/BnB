import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController    = TextEditingController();
  String _selectedRole      = 'user';
  bool _isLoading           = false;
  bool _obscurePassword     = true;

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
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
              backgroundColor: const Color(0xFF93000A),
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
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Purple glow — top-right
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
          // Blue glow — bottom-left
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

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand name
                    const Text(
                      'B&B',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hero heading
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join your concierge dashboard today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Glass form card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 48,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name
                          const _FieldLabel('Full Name'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _nameController,
                            hintText: 'James Harrington',
                            suffixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Email
                          const _FieldLabel('Email Address'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _emailController,
                            hintText: 'james@harrington.com',
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: Icons.alternate_email,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Password
                          const _FieldLabel('Password'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _passwordController,
                            hintText: '••••••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: _obscurePassword
                                ? Icons.lock_outline
                                : Icons.lock_open_outlined,
                            onSuffixTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Phone
                          const _FieldLabel('Phone Number'),
                          const SizedBox(height: 6),
                          _InputField(
                            controller: _phoneController,
                            hintText: '+1 234 567 8900',
                            keyboardType: TextInputType.phone,
                            suffixIcon: Icons.phone_outlined,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Role
                          const _FieldLabel('Role'),
                          const SizedBox(height: 6),
                          _RoleDropdown(
                            value: _selectedRole,
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedRole = v);
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register button
                          GestureDetector(
                            onTap: _isLoading ? null : _register,
                            child: AnimatedOpacity(
                              opacity: _isLoading ? 0.7 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFA078FF),
                                      Color(0xFF00A2E6),
                                    ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x44A078FF),
                                      blurRadius: 20,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF3C0091)),
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF3C0091),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 14,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0x55D0BCFF),
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
        ],
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCBC3D7),
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.suffixIcon,
    this.onSuffixTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFFDAE2FD)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: const Color(0xFFCBC3D7).withValues(alpha: 0.30),
        ),
        filled: true,
        fillColor: const Color(0xFF0D1528),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.50)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        suffixIcon: GestureDetector(
          onTap: onSuffixTap,
          child: Icon(
            suffixIcon,
            size: 18,
            color: const Color(0xFFCBC3D7).withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

// ── Role dropdown ─────────────────────────────────────────────────────────────

class _RoleDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF171F33),
      style: const TextStyle(fontSize: 15, color: Color(0xFFDAE2FD)),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: const Color(0xFFCBC3D7).withValues(alpha: 0.35),
        size: 20,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0D1528),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.50)),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'user',
          child: Text('User'),
        ),
        DropdownMenuItem(
          value: 'worker',
          child: Text('Worker'),
        ),
      ],
    );
  }
}
