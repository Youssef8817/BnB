import 'dart:io';

import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:b_and_b/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? initialProperty;
  const AddPropertyScreen({super.key, this.initialProperty});

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey               = GlobalKey<FormState>();
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController       = TextEditingController();
  final _locationController    = TextEditingController();
  final _cityController        = TextEditingController();
  final _areaController        = TextEditingController();
  final _roomsController       = TextEditingController();
  List<File> _selectedImages   = [];
  bool _isLoading              = false;

  bool get _isEditing => widget.initialProperty != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.initialProperty!;
      _titleController.text       = p.title;
      _descriptionController.text = p.description;
      _priceController.text       = p.price.toStringAsFixed(0);
      _locationController.text    = p.location;
      _cityController.text        = p.city;
      _areaController.text        = p.areaMq.toStringAsFixed(0);
      _roomsController.text       = p.rooms.toString();
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
    final picker      = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages =
            pickedFiles.map((f) => File(f.path)).take(3).toList();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final bool hasImages = _selectedImages.isNotEmpty ||
        (_isEditing && widget.initialProperty!.images.isNotEmpty);

    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: AppColors.errorBg,
        ),
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
            widget.initialProperty!.id, data, _selectedImages);
      } else {
        await ApiService.createProperty(data, _selectedImages);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Property updated successfully'
                : 'Property added successfully'),
            backgroundColor: AppColors.surface,
          ),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      BackButton2(
                          onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Edit Property' : 'Add Property',
                            style: AppText.h3,
                          ),
                          Text(
                            _isEditing
                                ? 'Update your listing details'
                                : 'List a new property',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image picker
                          _ImagePickerSection(
                            selectedImages: _selectedImages,
                            isEditing: _isEditing,
                            existingCount:
                                widget.initialProperty?.images.length ?? 0,
                            onPick: _pickImages,
                            onRemove: (i) =>
                                setState(() => _selectedImages.removeAt(i)),
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item =
                                    _selectedImages.removeAt(oldIndex);
                                _selectedImages.insert(newIndex, item);
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Glass form card
                          GlassBox(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PremiumInputField(
                                  controller: _titleController,
                                  hintText: 'e.g. Penthouse Suite Downtown',
                                  label: 'Property Title',
                                  prefixIcon: Icons.title_rounded,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter the title'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                PremiumInputField(
                                  controller: _descriptionController,
                                  hintText:
                                      'Describe the property in detail…',
                                  label: 'Description',
                                  prefixIcon: Icons.notes_rounded,
                                  maxLines: 4,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter the description'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                // Price & Rooms
                                Row(
                                  children: [
                                    Expanded(
                                      child: PremiumInputField(
                                        controller: _priceController,
                                        hintText: '250000',
                                        label: 'Price (\$)',
                                        prefixIcon:
                                            Icons.attach_money_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: PremiumInputField(
                                        controller: _roomsController,
                                        hintText: '3',
                                        label: 'Rooms',
                                        prefixIcon: Icons.bed_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'Required';
                                          final n = int.tryParse(v.trim());
                                          if (n == null || n < 1 || n > 100)
                                            return '1–100';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Area & City
                                Row(
                                  children: [
                                    Expanded(
                                      child: PremiumInputField(
                                        controller: _areaController,
                                        hintText: '120',
                                        label: 'Area (m²)',
                                        prefixIcon:
                                            Icons.square_foot_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: PremiumInputField(
                                        controller: _cityController,
                                        hintText: 'New York',
                                        label: 'City',
                                        prefixIcon:
                                            Icons.location_city_rounded,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                PremiumInputField(
                                  controller: _locationController,
                                  hintText: '123 Park Avenue, Manhattan',
                                  label: 'Location / Address',
                                  prefixIcon: Icons.location_on_outlined,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter the location'
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          GradientButton(
                            label: _isEditing
                                ? 'Update Property'
                                : 'Submit Property',
                            icon: Icons.check_rounded,
                            onTap: _isLoading ? null : _submit,
                            isLoading: _isLoading,
                            height: 54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image picker section ──────────────────────────────────────────────────────

class _ImagePickerSection extends StatelessWidget {
  final List<File> selectedImages;
  final bool isEditing;
  final int existingCount;
  final VoidCallback onPick;
  final void Function(int) onRemove;
  final void Function(int, int) onReorder;

  const _ImagePickerSection({
    required this.selectedImages,
    required this.isEditing,
    required this.existingCount,
    required this.onPick,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Photos',
          style: AppText.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),

        if (selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 110,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              onReorder: onReorder,
              itemBuilder: (_, i) => Padding(
                key: ValueKey(selectedImages[i].path),
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        selectedImages[i],
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ] else if (isEditing && existingCount > 0) ...[
          GlassBox(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.photo_library_outlined,
                    color: AppColors.textMuted, size: 20),
                const SizedBox(width: 10),
                Text(
                  '$existingCount existing photo(s) — pick new to replace',
                  style: AppText.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Select Photos  (up to 3)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
