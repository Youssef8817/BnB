import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/constants.dart';
import 'package:b_and_b/widgets/role_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:b_and_b/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  bool _editingPhone = false;
  final _phoneController = TextEditingController();
  bool _savingPhone = false;

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
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(Constants.userKey);
      if (userJson != null) {
        setState(() {
          _user = User.fromJson(json.decode(userJson));
          _isLoading = false;
        });
      } else {
        final user = await ApiService.getMe();
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, json.encode(updated.toJson()));
      setState(() {
        _user = updated;
        _editingPhone = false;
        _savingPhone = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Phone updated')));
      }
    } catch (e) {
      setState(() => _savingPhone = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddServiceDialog() {
    String selectedType = 'plumbing';
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Service Type'),
                  items: const [
                    DropdownMenuItem(value: 'plumbing', child: Text('Plumbing')),
                    DropdownMenuItem(value: 'painting', child: Text('Painting')),
                    DropdownMenuItem(value: 'tiling', child: Text('Tiling')),
                    DropdownMenuItem(value: 'electrical', child: Text('Electrical')),
                    DropdownMenuItem(value: 'carpentry', child: Text('Carpentry')),
                    DropdownMenuItem(value: 'finishing', child: Text('Finishing')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price per unit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Unit (e.g. hour, m²)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
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
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('No user data'))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text('Name: ${_user!.name}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Email: ${_user!.email}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      // Inline phone edit
                      if (_editingPhone)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                    labelText: 'Phone',
                                    isDense: true),
                                keyboardType: TextInputType.phone,
                                autofocus: true,
                              ),
                            ),
                            _savingPhone
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: _savePhone,
                                  ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  setState(() => _editingPhone = false),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text('Phone: ${_user!.phone}',
                                style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {
                                _phoneController.text = _user!.phone;
                                setState(() => _editingPhone = true);
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Role: ', style: TextStyle(fontSize: 16)),
                          RoleBadge(role: _user!.role),
                        ],
                      ),
                      if (_user!.role == 'worker') ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _showAddServiceDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Service'),
                        ),
                      ],
                      if (_user!.role != 'worker') ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => context.push('/my-requests'),
                          icon: const Icon(Icons.list_alt),
                          label: const Text('My Requests'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
