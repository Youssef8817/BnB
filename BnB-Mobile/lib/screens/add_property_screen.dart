// lib/screens/add_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/models/property.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? initialProperty;

  const AddPropertyScreen({Key? key, this.initialProperty}) : super(key: key);

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _roomsController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isLoading = false;

  bool get _isEditing => widget.initialProperty != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.initialProperty!;
      _titleController.text = p.title;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toStringAsFixed(0);
      _locationController.text = p.location;
      _cityController.text = p.city;
      _areaController.text = p.areaMq.toStringAsFixed(0);
      _roomsController.text = p.rooms.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles
            .map((file) => File(file.path))
            .take(3)
            .toList();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bool hasImages =
        _selectedImages.isNotEmpty || (_isEditing && widget.initialProperty!.images.isNotEmpty);

    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'title':       _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price':       _priceController.text.trim(),
        'location':    _locationController.text.trim(),
        'city':        _cityController.text.trim(),
        'area_m2':     _areaController.text.trim(),
        'rooms':       _roomsController.text.trim(),
      };

      if (_isEditing) {
        await ApiService.updateProperty(
          widget.initialProperty!.id,
          data,
          _selectedImages,
        );
      } else {
        await ApiService.createProperty(data, _selectedImages);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Property updated successfully' : 'Property added successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Property' : 'Add Property'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please enter the title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 4,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter the description'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please enter the price' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter the location'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please enter the city' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Area (m²)',
                    prefixIcon: Icon(Icons.square_foot),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please enter the area' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roomsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Rooms',
                    prefixIcon: Icon(Icons.hotel),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter the number of rooms'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Images (up to 3)'),
                ),
                const SizedBox(height: 12),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _selectedImages.removeAt(oldIndex);
                          _selectedImages.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (_, index) => Padding(
                        key: ValueKey(_selectedImages[index].path),
                        padding: const EdgeInsets.all(4.0),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImages[index],
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedImages.removeAt(index)),
                                child: Container(
                                  color: Colors.black54,
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_isEditing && widget.initialProperty!.images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${widget.initialProperty!.images.length} existing image(s) — pick new ones to replace',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                else
                  const Text('No images selected'),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_isEditing ? 'Update Property' : 'Submit Property'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
