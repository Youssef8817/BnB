import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/user.dart';
import 'package:b_and_b/services/api_service.dart';
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
  bool _isLoading     = true;
  bool _editingPhone  = false;
  bool _savingPhone   = false;
  final _phoneController = TextEditingController();

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

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
      final prefs   = await SharedPreferences.getInstance();
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
            backgroundColor: const Color(0xFF93000A),
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
            backgroundColor: const Color(0xFF93000A),
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
            backgroundColor: const Color(0xFF93000A),
          ),
        );
      }
    }
  }

  void _showAddServiceDialog() {
    String selectedType       = 'plumbing';
    final descController      = TextEditingController();
    final priceController     = TextEditingController();
    final unitController      = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF171F33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Add Service',
            style: TextStyle(color: _onSurface, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: const Color(0xFF171F33),
                  style: const TextStyle(color: _onSurface),
                  decoration: _dialogInputDecoration('Service Type'),
                  items: const [
                    DropdownMenuItem(value: 'plumbing',   child: Text('Plumbing')),
                    DropdownMenuItem(value: 'painting',   child: Text('Painting')),
                    DropdownMenuItem(value: 'tiling',     child: Text('Tiling')),
                    DropdownMenuItem(value: 'electrical', child: Text('Electrical')),
                    DropdownMenuItem(value: 'carpentry',  child: Text('Carpentry')),
                    DropdownMenuItem(value: 'finishing',  child: Text('Finishing')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: _onSurface),
                  decoration: _dialogInputDecoration('Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: _onSurface),
                  decoration: _dialogInputDecoration('Price per unit'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  style: const TextStyle(color: _onSurface),
                  decoration: _dialogInputDecoration('Unit (e.g. hour, m²)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: _onSurfaceVariant.withValues(alpha: 0.7))),
            ),
            GestureDetector(
              onTap: () async {
                if (descController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    unitController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                try {
                  await ApiService.createWorkerService({
                    'type': selectedType,
                    'description': descController.text.trim(),
                    'price_per_unit':
                        double.tryParse(priceController.text.trim()) ?? 0,
                    'unit': unitController.text.trim(),
                    'is_available': true,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service added!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: const Color(0xFF93000A),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3C0091),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _onSurfaceVariant.withValues(alpha: 0.7)),
      filled: true,
      fillColor: const Color(0xFF0D1528),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primary.withValues(alpha: 0.50)),
      ),
    );
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

          // Content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primary),
                  )
                : _user == null
                    ? const Center(
                        child: Text(
                          'No user data',
                          style: TextStyle(color: _onSurfaceVariant),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Back arrow
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.10)),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _primary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Brand
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

                            // Heading
                            const Text(
                              'My Profile',
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
                            Text(
                              _user!.email ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Avatar + role
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x44A078FF),
                                          blurRadius: 20,
                                          offset: Offset(0, 6),
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
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF3C0091),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  RoleBadge(role: _user!.role ?? ''),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Info card
                            _GlassCard(
                              child: Column(
                                children: [
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Name',
                                    value: _user!.name,
                                  ),
                                  _Divider(),
                                  _InfoRow(
                                    icon: Icons.alternate_email,
                                    label: 'Email',
                                    value: _user!.email ?? '',
                                  ),
                                  _Divider(),

                                  // Phone row with inline edit
                                  if (_editingPhone)
                                    _PhoneEditRow(
                                      controller: _phoneController,
                                      isSaving: _savingPhone,
                                      onSave: _savePhone,
                                      onCancel: () =>
                                          setState(() => _editingPhone = false),
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
                                          setState(() => _editingPhone = true);
                                        },
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: _primary.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Worker actions
                            if (_user!.role == 'worker')
                              _ActionButton(
                                icon: Icons.add_circle_outline,
                                label: 'Add Service',
                                onTap: _showAddServiceDialog,
                              ),

                            // User actions
                            if (_user!.role != 'worker')
                              _ActionButton(
                                icon: Icons.list_alt_outlined,
                                label: 'My Requests',
                                onTap: () => context.push('/my-requests'),
                              ),

                            const SizedBox(height: 16),

                            // Logout button
                            GestureDetector(
                              onTap: _logout,
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFA078FF), Color(0xFF00A2E6)],
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
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.logout,
                                        color: Color(0xFF3C0091), size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3C0091),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
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
}

// ── Glass card ────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 48,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
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
          Icon(icon, size: 18,
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFCBC3D7).withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFDAE2FD),
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
          Icon(Icons.phone_outlined, size: 18,
              color: const Color(0xFFD0BCFF).withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 15, color: Color(0xFFDAE2FD)),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF0D1528),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  borderSide: BorderSide(
                      color: const Color(0xFFD0BCFF).withValues(alpha: 0.50)),
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
                      strokeWidth: 2, color: Color(0xFFD0BCFF)),
                )
              : GestureDetector(
                  onTap: onSave,
                  child: const Icon(Icons.check_circle_outline,
                      color: Color(0xFFA078FF), size: 22),
                ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onCancel,
            child: Icon(Icons.cancel_outlined,
                color: const Color(0xFFCBC3D7).withValues(alpha: 0.5),
                size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD0BCFF), size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDAE2FD),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: const Color(0xFFCBC3D7).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
