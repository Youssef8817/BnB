import 'dart:convert';

import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/user.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = false;
  User? _owner; // To store the owner details if not already in the property
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _checkIfOwner();
    _fetchOwner();
  }

  Future<void> _checkIfOwner() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(Constants.userKey);
    if (userJson != null) {
      final Map<String, dynamic> userMap = json.decode(userJson);
      final int currentUserId = userMap['id'];
      setState(() {
        _isOwner = (currentUserId == widget.property.ownerId);
      });
    }
  }

  Future<void> _fetchOwner() async {
    try {
      final owner = await ApiService.getUser(widget.property.ownerId);
      setState(() {
        _owner = owner;
      });
    } catch (e) {
      // If we can't fetch the owner, we'll just show a message or use null.
      // For now, we'll just leave _owner as null and handle it in the UI.
    }
  }

  Future<void> _updatePropertyStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.updatePropertyStatus(widget.property.id, newStatus);
      // Update the property's status in the state
      setState(() {
        // We are not updating the property object in the state because it's passed in.
        // In a real app, we might update the parent's state, but for simplicity,
        // we'll just show a snackbar and let the user refresh if needed.
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProperty() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteProperty(widget.property.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openFullscreen(BuildContext context, int index, String heroTag) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Hero(
                  tag: heroTag,
                  child: CachedNetworkImage(
                    imageUrl: widget.property.images[index].fullUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callOwner() async {
    final phone = _owner?.phone ?? '';
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available')),
        );
      }
      return;
    }

    final Uri uri = Uri.parse('tel:$phone');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // fall through to clipboard fallback
    }

    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No dialer found. Number copied: $phone')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.title),
        actions: [
          if (_isOwner)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await context.push(
                    '/properties/add',
                    extra: widget.property,
                  );
                  if (result == true) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Property updated successfully')),
                    );
                  }
                } else if (value == 'delete') {
                  _deleteProperty();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Property'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Property'),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: ListView(
        children: [
          // Image PageView with Hero + fullscreen tap
          SizedBox(
            height: 250,
            child: widget.property.images.isEmpty
                ? const Center(child: Icon(Icons.image_not_supported))
                : PageView.builder(
                    itemCount: widget.property.images.length,
                    itemBuilder: (context, index) {
                      final tag = 'property_image_${widget.property.id}_$index';
                      return GestureDetector(
                        onTap: () => _openFullscreen(context, index, tag),
                        child: Hero(
                          tag: tag,
                          child: CachedNetworkImage(
                            imageUrl: widget.property.images[index].fullUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Dots indicator
          if (widget.property.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.property.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(
                        index == 0 ? 0.9 : 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.property.formattedPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Location: ${widget.property.location}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'City: ${widget.property.city}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Area: ${widget.property.areaMq.toStringAsFixed(0)} m²',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rooms: ${widget.property.rooms}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.property.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                // Call Owner button
                ElevatedButton.icon(
                  onPressed: _callOwner,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Owner'),
                ),
                const SizedBox(height: 16),
                // Status dropdown (only for owner)
                if (_isOwner)
                  DropdownButtonFormField<String>(
                    initialValue: widget.property.status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'sold',
                        child: Text('Sold'),
                      ),
                    ],
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _updatePropertyStatus(newStatus);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
