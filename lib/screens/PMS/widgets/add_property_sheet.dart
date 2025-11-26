import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property_models.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/app_form_styles.dart';
import 'dart:typed_data';
import '../services/properties_service.dart';
import '../../../widgets/common_app_bar.dart';

class AddPropertySheet extends StatefulWidget {
  final Property? property;
  final void Function(Property)? onPropertyAdded;

  const AddPropertySheet({super.key, this.property, this.onPropertyAdded});

  @override
  State<AddPropertySheet> createState() => _AddPropertySheetState();
}

class _AddPropertySheetState extends State<AddPropertySheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSaving = false;

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
    _nameCtrl = TextEditingController(text: widget.property?.name ?? '');
    _roomsCtrl = TextEditingController(text: (widget.property?.capacity ?? 1).toString());
    _descriptionCtrl = TextEditingController(text: widget.property?.description ?? '');
    _addressCtrl = TextEditingController(text: widget.property?.address ?? '');
    _cityCtrl = TextEditingController(text: widget.property?.location ?? '');
    _stateCtrl = TextEditingController();
    _countryCtrl = TextEditingController(text: '');
    _pincodeCtrl = TextEditingController(text: '');
    _emailCtrl = TextEditingController(text: widget.property?.ownerEmail ?? '');
    _phoneCtrl = TextEditingController(text: widget.property?.ownerPhone ?? '');
    _amenityCtrl = TextEditingController();
    _amenities = List<String>.from(widget.property?.amenities ?? const []);
    _selectedType = widget.property?.type ?? PropertyType.resort;
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
        title: 'Add Property',
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
                        child: Text('Previous', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
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
        Text('Amenities *', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
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
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a logo and additional images to showcase your property',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),
        _buildRow(
          left: _buildUploadTile(
            title: 'Property Logo *',
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
        if (_logoBytes == null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A property logo is required to complete the setup',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF92400E),
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
      return Text('No amenities added yet', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)));
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
        Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
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
                  Text('Click to upload', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(hint, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSave() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    // Client validations first so we don't show a loader and then early-return
    if (_amenities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one amenity'), backgroundColor: Colors.red));
      return;
    }
    if (_stateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('State is required'), backgroundColor: Colors.red));
      return;
    }
    if (_countryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Country is required'), backgroundColor: Colors.red));
      return;
    }
    if (_pincodeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pincode is required'), backgroundColor: Colors.red));
      return;
    }
    if (_logoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property logo is required'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isSaving = true; });
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
            ),
            SizedBox(height: 16),
            Text('Creating property and uploading images...'),
          ],
        ),
      ),
    );

    try {
      // Call API to create property
      final result = await PropertiesService.createProperty(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        postalCode: _pincodeCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        totalRooms: int.tryParse(_roomsCtrl.text.trim()) ?? 1,
        propertyType: PropertyHelper.getTypeLabel(_selectedType).toLowerCase(),
        amenities: _amenities,
      );

      if (result['success'] == true) {
        final propertyId = result['data']?['id']?.toString() ?? 
                          result['data']?['property']?['id']?.toString();
        
        if (propertyId == null || propertyId.isEmpty) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Property created but no ID returned from server'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // Upload logo if selected
        if (_logoBytes != null) {
          try {
            final logoResult = await PropertiesService.uploadPropertyLogoWithFallback(
              propertyId: propertyId,
              logoBytes: _logoBytes!,
            );
            if (logoResult['success'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Property created but logo upload failed: ${logoResult['message']}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            } else {
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Property created but logo upload error: ${e.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        
        // Upload additional images if selected
        if (_moreImageBytes.isNotEmpty) {
          try {
            final imagesResult = await PropertiesService.uploadPropertyImagesWithFallback(
              propertyId: propertyId,
              imageBytesList: _moreImageBytes,
            );
            if (imagesResult['success'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Property created but images upload failed: ${imagesResult['message']}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            } else {
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Property created but images upload error: ${e.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }

        Navigator.of(context).pop();

        // Build a local Property model from form values (API can be parsed on list refresh)
        final created = Property(
          id: propertyId,
          name: _nameCtrl.text.trim(),
          capacity: int.tryParse(_roomsCtrl.text.trim()) ?? 1,
          description: _descriptionCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          location: _cityCtrl.text.trim(),
          pincode: _pincodeCtrl.text.trim(),
          type: _selectedType,
          ownerEmail: _emailCtrl.text.trim(),
          ownerPhone: _phoneCtrl.text.trim(),
          amenities: _amenities,
          images: const [],
        );
        if (widget.onPropertyAdded != null) {
          widget.onPropertyAdded!(created);
        }
        Navigator.of(context).pop(created);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property created successfully'), backgroundColor: Colors.green));
      } else {
        Navigator.of(context).pop();
        final msg = (result['message'] ?? 'Failed to create property').toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      } else {
        _isSaving = false;
      }
    }
  }
}


