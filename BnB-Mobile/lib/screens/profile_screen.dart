import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/user.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:b_and_b/widgets/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading    = true;
  bool _editingPhone = false;
  bool _savingPhone  = false;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final prefs    = await SharedPreferences.getInstance();
      final userJson = prefs.getString(Constants.userKey);
      if (userJson != null) {
        setState(() {
          _user      = User.fromJson(json.decode(userJson));
          _isLoading = false;
        });
      } else {
        final user = await ApiService.getMe();
        setState(() {
          _user      = user;
          _isLoading = false;
        });
      }
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

  Future<void> _savePhone() async {
    final newPhone = _phoneController.text.trim();
    if (newPhone.isEmpty) return;
    setState(() => _savingPhone = true);
    try {
      final updated = await ApiService.updateProfile({'phone': newPhone});
      final prefs   = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, json.encode(updated.toJson()));
      setState(() {
        _user         = updated;
        _editingPhone = false;
        _savingPhone  = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone updated')),
        );
      }
    } catch (e) {
      setState(() => _savingPhone = false);
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

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.logout();
      if (mounted) context.go('/login');
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

  void _showAddServiceDialog() {
    String selectedType          = 'plumbing';
    final descController         = TextEditingController();
    final priceController        = TextEditingController();
    final unitController         = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Service', style: AppText.h4),
                const SizedBox(height: 20),
                // Service type dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      dropdownColor: AppColors.surfaceHigh,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 15),
                      icon: const Icon(Icons.expand_more_rounded,
                          color: AppColors.textMuted),
                      items: const [
                        DropdownMenuItem(
                            value: 'plumbing',
                            child: Text('Plumbing')),
                        DropdownMenuItem(
                            value: 'painting',
                            child: Text('Painting')),
                        DropdownMenuItem(
                            value: 'tiling', child: Text('Tiling')),
                        DropdownMenuItem(
                            value: 'electrical',
                            child: Text('Electrical')),
                        DropdownMenuItem(
                            value: 'carpentry',
                            child: Text('Carpentry')),
                        DropdownMenuItem(
                            value: 'finishing',
                            child: Text('Finishing')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => selectedType = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _DialogInput(
                  controller: descController,
                  hintText: 'Description',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DialogInput(
                        controller: priceController,
                        hintText: 'Price per unit',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogInput(
                        controller: unitController,
                        hintText: 'Unit (e.g. hour)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: GlassBox(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          child: const Text('Cancel',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (descController.text.trim().isEmpty ||
                              priceController.text.trim().isEmpty ||
                              unitController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please fill all fields')),
                            );
                            return;
                          }
                          Navigator.of(ctx).pop();
                          try {
                            await ApiService.createWorkerService({
                              'type': selectedType,
                              'description':
                                  descController.text.trim(),
                              'price_per_unit':
                                  double.tryParse(
                                          priceController.text.trim()) ??
                                      0,
                              'unit': unitController.text.trim(),
                              'is_available': true,
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Service added!')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: AppColors.errorBg,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: AppColors.gradientPrimary,
                          ),
                          child: const Text(
                            'Add',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
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
    );
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

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accent))
                : _user == null
                    ? Center(
                        child: Text('No user data',
                            style: AppText.bodySmall))
                    : SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(24, 24, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Back
                            Align(
                              alignment: Alignment.centerLeft,
                              child: BackButton2(
                                  onTap: () => context.pop()),
                            ),
                            const SizedBox(height: 24),

                            // Avatar + name
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.gradientPrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accentDeep
                                              .withValues(alpha: 0.40),
                                          blurRadius: 28,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        (_user!.name.isNotEmpty
                                                ? _user!.name[0]
                                                : '?')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ShaderMask(
                                    shaderCallback: (r) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFFB69EFF),
                                        Color(0xFF4FC3F7)
                                      ],
                                    ).createShader(r),
                                    child: Text(
                                      _user!.name,
                                      style: AppText.h2.copyWith(
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(_user!.email ?? '',
                                      style: AppText.bodySmall),
                                  const SizedBox(height: 10),
                                  RoleBadge(role: _user!.role ?? ''),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Info card
                            GlassBox(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Column(
                                children: [
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Name',
                                    value: _user!.name,
                                  ),
                                  Divider(
                                      height: 1,
                                      color: Colors.white
                                          .withValues(alpha: 0.06)),
                                  _InfoRow(
                                    icon: Icons.alternate_email,
                                    label: 'Email',
                                    value: _user!.email ?? '',
                                  ),
                                  Divider(
                                      height: 1,
                                      color: Colors.white
                                          .withValues(alpha: 0.06)),
                                  if (_editingPhone)
                                    _PhoneEditRow(
                                      controller: _phoneController,
                                      isSaving: _savingPhone,
                                      onSave: _savePhone,
                                      onCancel: () => setState(
                                          () => _editingPhone = false),
                                    )
                                  else
                                    _InfoRow(
                                      icon: Icons.phone_outlined,
                                      label: 'Phone',
                                      value: _user!.phone ?? '—',
                                      trailing: GestureDetector(
                                        onTap: () {
                                          _phoneController.text =
                                              _user!.phone ?? '';
                                          setState(
                                              () => _editingPhone = true);
                                        },
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: AppColors.accent
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Worker actions
                            if (_user!.role == 'worker')
                              _NavButton(
                                icon: Icons.add_circle_outline,
                                label: 'Add Service',
                                onTap: _showAddServiceDialog,
                              ),

                            // User actions
                            if (_user!.role != 'worker')
                              _NavButton(
                                icon: Icons.list_alt_outlined,
                                label: 'My Requests',
                                onTap: () =>
                                    context.push('/my-requests'),
                              ),

                            const SizedBox(height: 16),

                            GradientButton(
                              label: 'Logout',
                              icon: Icons.logout_rounded,
                              onTap: _logout,
                              height: 54,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: AppColors.accent.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppText.label,
                ),
                const SizedBox(height: 2),
                Text(value, style: AppText.body.copyWith(fontSize: 15)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Phone edit row ────────────────────────────────────────────────────────────

class _PhoneEditRow extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _PhoneEditRow({
    required this.controller,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.phone_outlined,
              size: 18,
              color: AppColors.accent.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.accentDeep, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accent),
                )
              : GestureDetector(
                  onTap: onSave,
                  child: const Icon(Icons.check_circle_outline,
                      color: AppColors.accent, size: 22),
                ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onCancel,
            child: Icon(Icons.cancel_outlined,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassBox(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: AppText.body.copyWith(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dialog input ──────────────────────────────────────────────────────────────

class _DialogInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;

  const _DialogInput({
    required this.controller,
    required this.hintText,
    this.maxLines     = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
          fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted.withValues(alpha: 0.30),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppColors.accentDeep, width: 1.5),
        ),
      ),
    );
  }
}
