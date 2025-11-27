import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_form_styles.dart';
import '../models/property_models.dart';
import '../services/properties_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../widgets/common_app_bar.dart';

class EditPropertyDetails extends StatefulWidget {
  final Property property;
  final VoidCallback? onPropertyUpdated;

  const EditPropertyDetails({
    super.key, 
    required this.property,
    this.onPropertyUpdated,
  });

  @override
  State<EditPropertyDetails> createState() => _EditPropertyDetailsState();
}

class _EditPropertyDetailsState extends State<EditPropertyDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  late TextEditingController _nameCtrl;
  late TextEditingController _roomsCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _amenityCtrl;
  List<String> _amenities = const [];

  // Image picking state
  final ImagePicker _picker = ImagePicker();
  Uint8List? _logoBytes;
  List<Uint8List> _moreImageBytes = const [];

  PropertyType _selectedType = PropertyType.resort;

  // Step titles
  final List<String> _stepTitles = [
    'Basic Information',
    'Location Details',
    'Contact Information',
    'Amenities',
    'Images'
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.property.name);
    _roomsCtrl = TextEditingController(text: widget.property.capacity.toString());
    _descriptionCtrl = TextEditingController(text: widget.property.description);
    _addressCtrl = TextEditingController(text: widget.property.address);
    // Parse location string like "City, State, Country" into individual fields
    final parts = _splitLocation(widget.property.location);
    _cityCtrl = TextEditingController(text: parts['city'] ?? '');
    _stateCtrl = TextEditingController(text: parts['state'] ?? '');
    _countryCtrl = TextEditingController(text: parts['country'] ?? '');
    _pincodeCtrl = TextEditingController(text: widget.property.pincode);
    _emailCtrl = TextEditingController(text: widget.property.ownerEmail);
    _phoneCtrl = TextEditingController(text: widget.property.ownerPhone);
    _amenityCtrl = TextEditingController();
    _amenities = List<String>.from(widget.property.amenities);
    _selectedType = widget.property.type;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomsCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pincodeCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _amenityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CommonAppBar.simple(
        title: 'Edit Property Details',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF8FAFC)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: AppFormStyles.stepHeader(_stepTitles[_currentStep], _currentStep, _stepTitles.length),
            ),
            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Previous', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                  child: ElevatedButton(
                      onPressed: _currentStep == _stepTitles.length - 1 ? _onSave : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentStep == _stepTitles.length - 1 ? 'Save Changes' : 'Next',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildLocationStep();
      case 2:
        return _buildContactStep();
      case 3:
        return _buildAmenitiesStep();
      case 4:
        return _buildImagesStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Property Name *', _nameCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        _buildRow(
          left: _buildDropdown('Property Type *'),
          right: _buildTextField('Number of Rooms *', _roomsCtrl, keyboardType: TextInputType.number, validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final value = int.tryParse(v);
            if (value == null || value < 1) return 'Enter a valid number';
            return null;
          }),
        ),
        const SizedBox(height: 16),
        _buildMultiline('Description *', _descriptionCtrl),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Address *', _addressCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('City *', _cityCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('State *', _stateCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Country *', _countryCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Pincode *', _pincodeCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
          ],
        ),
      ],
    );
  }

  Widget _buildContactStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          left: _buildTextField('Contact Email *', _emailCtrl, keyboardType: TextInputType.emailAddress, validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
            if (!regex.hasMatch(v.trim())) return 'Enter a valid email';
            return null;
          }),
          right: _buildTextField('Contact Phone *', _phoneCtrl, keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        ),
      ],
    );
  }

  Widget _buildAmenitiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities *', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amenityCtrl,
                decoration: _inputDecoration().copyWith(hintText: 'Add an amenity...'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _addAmenity,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAmenityChips(),
      ],
    );
  }

  Widget _buildImagesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Images',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your property logo and additional images',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),
        _buildRow(
          left: _buildUploadTile(
            title: 'Property Logo',
            hint: 'Click to upload\nPNG, JPG, JPEG up to 2MB',
            onTap: _pickLogo,
            preview: _logoBytes == null
                ? null
                : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_logoBytes!, height: 80, width: 120, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _logoBytes = null),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          right: _buildUploadTile(
            title: 'Additional Images',
            hint: 'Click to upload multiple\nPNG, JPG, JPEG up to 5MB each',
            onTap: _pickMoreImages,
            preview: _moreImageBytes.isEmpty
                ? null
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moreImageBytes
                        .asMap()
                        .entries
                        .map((entry) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                entry.value, 
                                height: 56, 
                                width: 80, 
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(entry.key),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (_logoBytes == null && _moreImageBytes.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No new images selected. Current property images will remain unchanged.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _addAmenity() {
    final value = _amenityCtrl.text.trim();
    if (value.isEmpty) return;
    if (_amenities.any((a) => a.toLowerCase() == value.toLowerCase())) {
      _amenityCtrl.clear();
      return;
    }
    setState(() {
      _amenities = [..._amenities, value];
      _amenityCtrl.clear();
    });
  }

  Widget _buildAmenityChips() {
    if (_amenities.isEmpty) {
      return Text('No amenities added yet', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _amenities.map((amenity) {
        return InputChip(
          label: Text(amenity),
          onDeleted: () {
            setState(() {
              _amenities = _amenities.where((a) => a != amenity).toList();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRow({required Widget left, required Widget right}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 700;
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFormStyles.labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: AppFormStyles.inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildMultiline(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFormStyles.labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          decoration: AppFormStyles.inputDecoration(),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFormStyles.labelStyle()),
        const SizedBox(height: 8),
        DropdownButtonFormField<PropertyType>(
          value: _selectedType,
          items: PropertyType.values
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(PropertyHelper.getTypeLabel(t)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
          decoration: AppFormStyles.inputDecoration(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (picked == null) return;
      
      final bytes = await picked.readAsBytes();
      
      // Check file size (2MB limit)
      if (bytes.length > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo file size must be less than 2MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() => _logoBytes = bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking logo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickMoreImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (picked.isEmpty) return;
      
      final lists = await Future.wait(picked.map((x) => x.readAsBytes()));
      
      // Check file sizes (5MB limit per image)
      final validImages = <Uint8List>[];
      for (int i = 0; i < lists.length; i++) {
        if (lists[i].length > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image ${i + 1} file size must be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          validImages.add(lists[i]);
        }
      }
      
      if (validImages.isNotEmpty) {
        setState(() => _moreImageBytes = [..._moreImageBytes, ...validImages]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _moreImageBytes = _moreImageBytes.asMap().entries
          .where((entry) => entry.key != index)
          .map((entry) => entry.value)
          .toList();
    });
  }

  Widget _buildUploadTile({required String title, required String hint, required VoidCallback onTap, Widget? preview}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1, style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (preview != null) preview else const Icon(Icons.image_outlined, size: 36, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 10),
                  Text('Click to upload', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(hint, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
        ),
      ),
    );

    try {
      final updateData = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'type': _selectedType.name,
        'description': _descriptionCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'postal_code': _pincodeCtrl.text.trim(),
        'contact_email': _emailCtrl.text.trim(),
        'contact_phone': _phoneCtrl.text.trim(),
        'room_count': int.tryParse(_roomsCtrl.text.trim()) ?? widget.property.capacity,
        'amenities': _amenities,
      }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

      final resp = await PropertiesService.updateProperty(
        propertyId: widget.property.id,
        updateData: updateData,
      );

      if (resp['success'] == true) {
        // Upload logo if selected
        if (_logoBytes != null) {
          print('📤 Uploading property logo...');
          try {
            final logoResult = await PropertiesService.uploadPropertyLogoWithFallback(
              propertyId: widget.property.id,
              logoBytes: _logoBytes!,
            );
            if (logoResult['success'] != true) {
              print('⚠️ Logo upload failed: ${logoResult['message']}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logo upload failed: ${logoResult['message']}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      // Retry logo upload
                      _uploadLogo();
                    },
                  ),
                ),
              );
            } else {
              print('✅ Logo uploaded successfully');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logo uploaded successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            print('💥 Logo upload error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logo upload error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        
        // Upload additional images if selected
        if (_moreImageBytes.isNotEmpty) {
          print('📤 Uploading ${_moreImageBytes.length} property images...');
          try {
            final imagesResult = await PropertiesService.uploadPropertyImagesWithFallback(
              propertyId: widget.property.id,
              imageBytesList: _moreImageBytes,
            );
            if (imagesResult['success'] != true) {
              print('⚠️ Images upload failed: ${imagesResult['message']}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Images upload failed: ${imagesResult['message']}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      // Retry images upload
                      _uploadImages();
                    },
                  ),
                ),
              );
            } else {
              print('✅ Images uploaded successfully');
              print('📸 Upload response data: ${imagesResult['data']}');
              
              // Update property with new image URLs if provided
              if (imagesResult['data'] != null && imagesResult['data']['images'] != null) {
                final newImages = List<String>.from(imagesResult['data']['images']);
                print('🖼️ New image URLs: $newImages');
                // Note: The property will be updated when the parent screen refreshes
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_moreImageBytes.length} images uploaded successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            print('💥 Images upload error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Images upload error: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }

        Navigator.of(context).pop();

        // Notify parent to refresh property list
        if (widget.onPropertyUpdated != null) {
          widget.onPropertyUpdated!();
        }

        final updated = widget.property.copyWith(
          name: _nameCtrl.text.trim(),
          capacity: int.tryParse(_roomsCtrl.text.trim()) ?? widget.property.capacity,
          description: _descriptionCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          location: _composeLocation(),
          pincode: _pincodeCtrl.text.trim(),
          type: _selectedType,
          ownerEmail: _emailCtrl.text.trim(),
          ownerPhone: _phoneCtrl.text.trim(),
          amenities: _amenities,
        );
        if (mounted) {
          Navigator.of(context).pop(updated);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property updated successfully'), backgroundColor: Colors.green));
        }
      } else {
        Navigator.of(context).pop();
        if (mounted) {
          final status = resp['statusCode'] as int?;
          String msg = (resp['message'] ?? 'Failed to update property').toString();
          if (status == 403) {
            msg = "You don't have permission to edit this property.";
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  Map<String, String> _splitLocation(String? location) {
    if (location == null || location.trim().isEmpty) {
      return {};
    }
    final parts = location.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    String? city;
    String? state;
    String? country;
    if (parts.isNotEmpty) city = parts[0];
    if (parts.length > 1) state = parts[1];
    if (parts.length > 2) country = parts.sublist(2).join(', '); // handle extra commas gracefully
    return {
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
    };
  }

  String _composeLocation() {
    final parts = [
      _cityCtrl.text.trim(),
      _stateCtrl.text.trim(),
      _countryCtrl.text.trim(),
    ].where((s) => s.isNotEmpty).toList();
    return parts.join(', ');
  }

  // Retry methods for failed uploads
  Future<void> _uploadLogo() async {
    if (_logoBytes == null) return;
    
    try {
      final logoResult = await PropertiesService.uploadPropertyLogoWithFallback(
        propertyId: widget.property.id,
        logoBytes: _logoBytes!,
      );
      
      if (logoResult['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logo upload failed: ${logoResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logo upload error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_moreImageBytes.isEmpty) return;
    
    try {
      final imagesResult = await PropertiesService.uploadPropertyImagesWithFallback(
        propertyId: widget.property.id,
        imageBytesList: _moreImageBytes,
      );
      
      if (imagesResult['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_moreImageBytes.length} images uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Images upload failed: ${imagesResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Images upload error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


