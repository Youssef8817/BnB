import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:b_and_b/repositories/property_repository.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/widgets/property_card.dart';
import 'package:b_and_b/widgets/empty_state.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({Key? key}) : super(key: key);

  @override
  _MyPropertiesScreenState createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final PropertyRepository _propertyRepository = PropertyRepository();
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyProperties();
  }

  Future<void> _loadMyProperties() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _propertyRepository.getMine();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteProperty(int id) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteProperty(id);
      await _loadMyProperties(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property deleted successfully')),
        );
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

  Future<void> _updatePropertyStatus(int id, String status) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.updatePropertyStatus(id, status);
      await _loadMyProperties(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property status updated successfully')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? const EmptyState(
                  message: 'You have no properties yet',
                  icon: Icons.list_alt,
                )
              : ListView.builder(
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    final property = _properties[index];
                    return Dismissible(
                      key: Key(property.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await _deleteProperty(property.id);
                      },
                      child: ListTile(
                        leading: property.images.isNotEmpty
                            ? SizedBox(
                                width: 60,
                                height: 60,
                                child: CachedNetworkImage(
                                  imageUrl: property.images.first.fullUrl,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const SizedBox(
                                width: 60,
                                height: 60,
                                child: Icon(Icons.house, size: 40),
                              ),
                        title: Text(property.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${property.formattedPrice} • ${property.city}'),
                            Text(
                              '${property.rooms} rooms • ${property.areaMq.toStringAsFixed(0)}m²',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await context.push(
                                '/properties/add',
                                extra: property,
                              );
                              if (result == true) {
                                await _loadMyProperties();
                              }
                            } else if (value == 'status') {
                              // Show status change dialog
                              await _showStatusChangeDialog(property);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'status',
                              child: Text('Change Status'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showStatusChangeDialog(Property property) async {
    String _selected = property.status;
    final String? newStatus = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Property Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'available',
                groupValue: _selected,
                title: const Text('Available'),
                onChanged: (v) => setDialogState(() => _selected = v!),
              ),
              RadioListTile<String>(
                value: 'pending',
                groupValue: _selected,
                title: const Text('Pending'),
                onChanged: (v) => setDialogState(() => _selected = v!),
              ),
              RadioListTile<String>(
                value: 'sold',
                groupValue: _selected,
                title: const Text('Sold'),
                onChanged: (v) => setDialogState(() => _selected = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    if (newStatus != null && newStatus != property.status) {
      await _updatePropertyStatus(property.id, newStatus);
    }
  }
}