import 'dart:io';

import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? initialProperty;

  const AddPropertyScreen({super.key, this.initialProperty});

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController       = TextEditingController();
  final _locationController    = TextEditingController();
  final _cityController        = TextEditingController();
  final _areaController        = TextEditingController();
  final _roomsController       = TextEditingController();
  List<File> _selectedImages   = [];
  bool _isLoading              = false;

  static const Color _bg               = Color(0xFF0B1326);
  static const Color _primary          = Color(0xFFD0BCFF);
  static const Color _onSurface        = Color(0xFFDAE2FD);
  static const Color _onSurfaceVariant = Color(0xFFCBC3D7);

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
    final picker = ImagePicker();
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
          backgroundColor: Color(0xFF93000A),
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
            content: Text(_isEditing
                ? 'Property updated successfully'
                : 'Property added successfully'),
            backgroundColor: const Color(0xFF1A1040),
          ),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          // ── Purple glow — top-right ─────────────────────────────────
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
          // ── Blue glow — bottom-left ─────────────────────────────────
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

          // ── Scrollable content ──────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: _primary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Edit Property' : 'Add Property',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            _isEditing
                                ? 'Update your listing details'
                                : 'List a new property',
                            style: TextStyle(
                              fontSize: 13,
                              color: _onSurfaceVariant.withValues(alpha: 0.7),
                            ),
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
                          // ── Image picker ──────────────────────────
                          _ImagePickerSection(
                            selectedImages: _selectedImages,
                            isEditing: _isEditing,
                            existingCount: widget.initialProperty?.images.length ?? 0,
                            onPick: _pickImages,
                            onRemove: (i) =>
                                setState(() => _selectedImages.removeAt(i)),
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = _selectedImages.removeAt(oldIndex);
                                _selectedImages.insert(newIndex, item);
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── Glass form card ───────────────────────
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 40,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _FieldLabel('Property Title'),
                                const SizedBox(height: 6),
                                _InputField(
                                  controller: _titleController,
                                  hintText: 'e.g. Penthouse Suite Downtown',
                                  suffixIcon: Icons.title_rounded,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter the title'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                const _FieldLabel('Description'),
                                const SizedBox(height: 6),
                                _InputField(
                                  controller: _descriptionController,
                                  hintText:
                                      'Describe the property in detail...',
                                  suffixIcon: Icons.notes_rounded,
                                  maxLines: 4,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter the description'
                                      : null,
                                ),
                                const SizedBox(height: 18),

                                // Price & Rooms — side by side
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _FieldLabel('Price (\$)'),
                                          const SizedBox(height: 6),
                                          _InputField(
                                            controller: _priceController,
                                            hintText: '250000',
                                            suffixIcon:
                                                Icons.attach_money_rounded,
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Required'
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _FieldLabel('Rooms'),
                                          const SizedBox(height: 6),
                                          _InputField(
                                            controller: _roomsController,
                                            hintText: '3',
                                            suffixIcon: Icons.bed_rounded,
                                            keyboardType: TextInputType.number,
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return 'Required';
                                              }
                                              final n =
                                                  int.tryParse(v.trim());
                                              if (n == null ||
                                                  n < 1 ||
                                                  n > 100) {
                                                return '1–100';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Area & City — side by side
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _FieldLabel('Area (m²)'),
                                          const SizedBox(height: 6),
                                          _InputField(
                                            controller: _areaController,
                                            hintText: '120',
                                            suffixIcon:
                                                Icons.square_foot_rounded,
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Required'
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _FieldLabel('City'),
                                          const SizedBox(height: 6),
                                          _InputField(
                                            controller: _cityController,
                                            hintText: 'New York',
                                            suffixIcon:
                                                Icons.location_city_rounded,
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Required'
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                const _FieldLabel('Location / Address'),
                                const SizedBox(height: 6),
                                _InputField(
                                  controller: _locationController,
                                  hintText: '123 Park Avenue, Manhattan',
                                  suffixIcon: Icons.location_on_outlined,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Please enter the location'
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Submit button ─────────────────────────
                          GestureDetector(
                            onTap: _isLoading ? null : _submit,
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
                                    : Text(
                                        _isEditing
                                            ? 'Update Property'
                                            : 'Submit Property',
                                        style: const TextStyle(
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
        const _FieldLabel('Property Photos'),
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.photo_library_outlined,
                    color: Color(0xFFCBC3D7), size: 20),
                const SizedBox(width: 10),
                Text(
                  '$existingCount existing photo(s) — pick new to replace',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFFCBC3D7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Pick button
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD0BCFF).withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    color: Color(0xFFD0BCFF), size: 20),
                SizedBox(width: 8),
                Text(
                  'Select Photos  (up to 3)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD0BCFF),
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
  final IconData suffixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    required this.suffixIcon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
        suffixIcon: Icon(
          suffixIcon,
          size: 18,
          color: const Color(0xFFCBC3D7).withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
