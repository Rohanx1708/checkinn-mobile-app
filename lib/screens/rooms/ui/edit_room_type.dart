import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_form_styles.dart';
import '../models/room_models.dart';
import '../services/rooms_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class EditRoomType extends StatefulWidget {
  final RoomEntity room;

  const EditRoomType({super.key, required this.room});

  @override
  State<EditRoomType> createState() => _EditRoomTypeState();
}

class _EditRoomTypeState extends State<EditRoomType> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  late TextEditingController _nameCtrl;
  late TextEditingController _basePriceCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _floorStartCtrl;
  late TextEditingController _bedCtrl;
  late TextEditingController _amenityCtrl;
  late TextEditingController _sortOrderCtrl;

  RoomTypeOption _accommodation = RoomTypeOption.chalet;
  String _floor = 'Ground Floor (G)';
  String _viewType = 'Mountain View';
  int _maxOccupancy = 2;
  bool _autoNumbering = true;
  bool _isActive = true;

  List<String> _bedConfigs = const [];
  List<String> _amenities = const [];

  // Pricing tiers
  final List<String> _tierTypes = const ['Peak Season', 'Monsoon Season', 'Off Season', 'Weekend', 'Weekday'];
  final List<_PricingTier> _tiers = [];

  // Images
  final ImagePicker _picker = ImagePicker();
  List<Uint8List> _roomTypeImages = const [];

  // Step titles
  final List<String> _stepTitles = [
    'Basic Information',
    'Pricing & Capacity',
    'Description & Configuration',
    'Pricing Tiers',
    'Images & Settings'
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.room.name);
    _basePriceCtrl = TextEditingController(text: widget.room.price.toStringAsFixed(0));
    _quantityCtrl = TextEditingController(text: '1');
    _sizeCtrl = TextEditingController(text: '25');
    _descriptionCtrl = TextEditingController(text: widget.room.description);
    _floorStartCtrl = TextEditingController(text: '1');
    _bedCtrl = TextEditingController();
    _amenityCtrl = TextEditingController();
    _sortOrderCtrl = TextEditingController(text: '1');
    _amenities = List<String>.from(widget.room.amenities);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _basePriceCtrl.dispose();
    _quantityCtrl.dispose();
    _sizeCtrl.dispose();
    _descriptionCtrl.dispose();
    _floorStartCtrl.dispose();
    _bedCtrl.dispose();
    _amenityCtrl.dispose();
    _sortOrderCtrl.dispose();
    for (final t in _tiers) {
      t.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Room Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF0F172A),
                      ),
                      child: Text(
                        _currentStep == _stepTitles.length - 1 ? 'Create Room Type' : 'Next',
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
        return _buildPricingCapacityStep();
      case 2:
        return _buildDescriptionConfigStep();
      case 3:
        return _buildPricingTiersStep();
      case 4:
        return _buildImagesSettingsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text('Room Type Name *', _nameCtrl),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _dropdown<String>(
                                label: 'Floor *',
                                value: _floor,
                                items: const [
                                  'Ground Floor (G)',
                                  'First Floor (1)',
                                  'Second Floor (2)',
                                ],
                                onChanged: (v) => setState(() => _floor = v ?? _floor),
                                textStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dropdown<RoomTypeOption>(
                                label: 'Accommodation Type *',
                                value: _accommodation,
                                items: RoomTypeOption.values,
                                itemLabel: (v) => _accommodationLabel(v),
                                onChanged: (v) => setState(() => _accommodation = v ?? _accommodation),
                                textStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _numberingCard(),
      ],
    );
  }

  Widget _buildPricingCapacityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        Row(
                          children: [
                            Expanded(child: _text('Base Price (per night) *', _basePriceCtrl, keyboardType: TextInputType.number)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dropdown<int>(
                                label: 'Maximum Occupancy *',
                                value: _maxOccupancy,
                                items: const [1, 2, 3, 4, 5, 6],
                                onChanged: (v) => setState(() => _maxOccupancy = v ?? _maxOccupancy),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _text('Quantity Available *', _quantityCtrl, keyboardType: TextInputType.number)),
                            const SizedBox(width: 16),
                            Expanded(child: _text('Size (sqm)', _sizeCtrl, keyboardType: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _dropdown<String>(
                          label: 'View Type',
                          value: _viewType,
                          items: const ['Mountain View', 'City View', 'Ocean View'],
                          onChanged: (v) => setState(() => _viewType = v ?? _viewType),
                        ),
      ],
    );
  }

  Widget _buildDescriptionConfigStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        _multiline('Description *', _descriptionCtrl),
                        const SizedBox(height: 16),
                        Text('Bed Configuration', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bedCtrl,
                                decoration: _decoration().copyWith(hintText: 'e.g King Bed, Twin Beds'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _addBedConfig,
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
                        _buildChips(_bedConfigs, onRemove: (v) => setState(() => _bedConfigs = _bedConfigs.where((e) => e != v).toList())),
                        const SizedBox(height: 16),
                        Text('Room Amenities', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _amenityCtrl,
                                decoration: _decoration().copyWith(hintText: 'e.g., Free WiFi'),
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
                        _buildChips(_amenities, onRemove: (v) => setState(() => _amenities = _amenities.where((e) => e != v).toList())),
      ],
    );
  }

  Widget _buildPricingTiersStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pricing Tiers (Optional)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                            TextButton.icon(
                              onPressed: _addTier,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Tier'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: _tiers.map((tier) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _dropdown<String>(
                                          label: 'Type',
                                          value: tier.type,
                                          items: _tierTypes,
                                          onChanged: (v) => setState(() => tier.type = v ?? tier.type),
                                          textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 120,
                                        child: _text('Price', tier.priceCtrl, keyboardType: TextInputType.number),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _text('Description', tier.descCtrl),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _removeTier(tier),
                                      child: Text('Remove', style: GoogleFonts.poppins(color: Colors.red)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
      ],
    );
  }

  Widget _buildImagesSettingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                        Text('Room Type Images', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickRoomTypeImages,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, size: 36, color: Color(0xFF94A3B8)),
                                  const SizedBox(height: 8),
                                  Text('Click to upload or drag and drop', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('PNG, JPG, JPEG up to 5MB each', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_roomTypeImages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _roomTypeImages
                                .map((b) => ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(b, height: 64, width: 96, fit: BoxFit.cover),
                                    ))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Active + Sort Order
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _isActive,
                                  onChanged: (v) => setState(() => _isActive = v ?? _isActive),
                                ),
                                Text('Active (available for booking)', style: GoogleFonts.poppins(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 200,
                              child: _text('Sort Order', _sortOrderCtrl, keyboardType: TextInputType.number),
                            ),
                          ],
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

  Widget _row({required Widget left, required Widget right}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool narrow = screenWidth < 700;
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [left, const SizedBox(height: 16), right],
      );
    }
    return Row(children: [Expanded(child: left), const SizedBox(width: 16), Expanded(child: right)]);
  }

  Widget _text(String label, TextEditingController c, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFormStyles.labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: c,
          keyboardType: keyboardType,
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          decoration: AppFormStyles.inputDecoration(),
        ),
      ],
    );
  }

  Widget _multiline(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFormStyles.labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: c,
          minLines: 3,
          maxLines: 5,
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          decoration: AppFormStyles.inputDecoration(),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? itemLabel,
    required ValueChanged<T?> onChanged,
    TextStyle? textStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFormStyles.labelStyle()),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((it) => DropdownMenuItem<T>(
                    value: it,
                    child: Text(
                      itemLabel != null ? itemLabel(it) : it.toString(),
                      style: textStyle,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          style: textStyle,
          decoration: AppFormStyles.inputDecoration(),
        ),
      ],
    );
  }

  Widget _numberingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _autoNumbering,
                onChanged: (v) => setState(() => _autoNumbering = v ?? _autoNumbering),
              ),
              Text('Use automatic floor-based numbering', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          _row(
            left: _text('Floor Start Number', _floorStartCtrl, keyboardType: TextInputType.number),
            right: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Preview:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(
                  'This room type will be numbered as G${_floorStartCtrl.text.padLeft(2, '0')}',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF374151)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _accommodationLabel(RoomTypeOption opt) {
    switch (opt) {
      case RoomTypeOption.chalet:
        return 'Chalet';
      case RoomTypeOption.villa:
        return 'Villa';
      case RoomTypeOption.suite:
        return 'Suite';
      case RoomTypeOption.cabin:
        return 'Cabin';
    }
  }

  InputDecoration _decoration() {
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

  void _addBedConfig() {
    final value = _bedCtrl.text.trim();
    if (value.isEmpty) return;
    if (_bedConfigs.any((b) => b.toLowerCase() == value.toLowerCase())) {
      _bedCtrl.clear();
      return;
    }
    setState(() {
      _bedConfigs = [..._bedConfigs, value];
      _bedCtrl.clear();
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

  Widget _buildChips(List<String> items, {required ValueChanged<String> onRemove}) {
    if (items.isEmpty) {
      return Text('None added yet', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((it) => InputChip(label: Text(it), onDeleted: () => onRemove(it))).toList(),
    );
  }

  void _addTier() {
    setState(() {
      _tiers.add(_PricingTier(type: _tierTypes.first));
    });
  }

  void _removeTier(_PricingTier tier) {
    setState(() {
      tier.dispose();
      _tiers.remove(tier);
    });
  }

  Future<void> _pickRoomTypeImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(maxWidth: 1800);
    if (picked.isEmpty) return;
    final lists = await Future.wait(picked.map((x) => x.readAsBytes()));
    setState(() => _roomTypeImages = [..._roomTypeImages, ...lists]);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Show loading dialog
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
      // Update room type data
      final updateData = {
        'name': _nameCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'base_price': double.tryParse(_basePriceCtrl.text.trim()) ?? widget.room.price,
        'amenities': [
          ..._amenities,
          ..._bedConfigs.map((b) => 'Bed: $b'),
        ],
        // Add required fields that the server expects
        'floor': widget.room.floor,
        'floor_start_number': 1, // Default floor start number
        'auto_numbering': true, // Default auto numbering
        'accommodation_type': 'room', // Default accommodation type
        'max_occupancy': 2, // Default max occupancy
        'currency': 'INR', // Default currency
        'quantity': 1, // Default quantity
        'is_active': true, // Default to active
        'sort_order': 0, // Default sort order
      }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

      // Debug: Check if room type ID exists
      print('🔍 Attempting to update room type with ID: ${widget.room.id}');
      print('🔍 Room type ID type: ${widget.room.id.runtimeType}');
      
      // First, let's verify the room type exists by fetching it directly
      try {
        final roomTypeResult = await RoomsService.getRoomType(widget.room.id);
        if (roomTypeResult['success'] == true) {
          print('✅ Room type ${widget.room.id} exists and accessible');
          print('🔍 Room type data: ${roomTypeResult['data']}');
        } else {
          print('❌ Room type ${widget.room.id} NOT found or not accessible');
          print('❌ Error: ${roomTypeResult['message']}');
          
          // Also try to get the list to see what IDs are available
          final roomTypesList = await RoomsService.getRoomTypes();
          if (roomTypesList['data'] != null) {
            final roomTypes = roomTypesList['data'] as List;
            print('🔍 Available room type IDs: ${roomTypes.map((rt) => rt['id']).toList()}');
          }
        }
      } catch (e) {
        print('❌ Error fetching room type: $e');
      }
      
      final resp = await RoomsService.updateRoomType(
        roomTypeId: widget.room.id,
        updateData: updateData,
      );

      if (resp['success'] == true) {
        // Upload images if selected
        if (_roomTypeImages.isNotEmpty) {
          try {
            final imagesResult = await RoomsService.uploadRoomTypeImagesWithFallback(
              roomTypeId: widget.room.id,
              imageBytesList: _roomTypeImages,
            );
            if (imagesResult['success'] != true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Room type updated but images upload failed: ${imagesResult['message']}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Room type updated and ${_roomTypeImages.length} images uploaded successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Room type updated but images upload error: ${e.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }

        Navigator.of(context).pop(); // Close loading dialog
        
        // If images were uploaded, return a special value to trigger data refresh
        if (_roomTypeImages.isNotEmpty) {
          Navigator.of(context).pop('refresh'); // Return special value to trigger refresh
        } else {
          final updated = widget.room.copyWith(
            name: _nameCtrl.text.trim(),
            price: double.tryParse(_basePriceCtrl.text.trim()) ?? widget.room.price,
            description: _descriptionCtrl.text.trim(),
          );
          // Combine amenities and bed configs into a single amenities list for RoomEntity
          final combinedAmenities = [
            ..._amenities,
            ..._bedConfigs.map((b) => 'Bed: $b'),
          ];
          final withAmenities = updated.copyWith(amenities: combinedAmenities);
          Navigator.of(context).pop(withAmenities);
        }
      } else {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update room type: ${resp['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating room type: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// A small enum to represent types if not present in models
enum RoomTypeOption { chalet, villa, suite, cabin }

class _PricingTier {
  String type;
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  _PricingTier({required this.type});

  void dispose() {
    priceCtrl.dispose();
    descCtrl.dispose();
  }
}
