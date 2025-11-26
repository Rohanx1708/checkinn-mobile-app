import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property_models.dart';
import '../services/properties_service.dart';
import '../widgets/property_card.dart';
import 'edit_property_details.dart';
import '../widgets/add_property_sheet.dart';
import '../../../services/auth_service.dart';
import '../widgets/empty_state.dart';
import '../../../widgets/common_app_bar.dart';
import '../../Dashboard/widget/drawer_widget.dart';

class PmsUi extends StatefulWidget {
  const PmsUi({super.key});

  @override
  State<PmsUi> createState() => _PmsUiState();
}

class _PmsUiState extends State<PmsUi> {
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;
  PmsState _pmsState = const PmsState();

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PropertiesService.getProperties(
        page: 1,
        limit: 50,
      );

      if (result['success']) {
        final data = result['data'];
        List<Property> properties = [];
        
        if (data['properties'] != null) {
          // Handle properties array response
          for (var propertyData in data['properties']) {
            try {
              properties.add(Property.fromJson(propertyData));
            } catch (e) {
              // Skip invalid properties
            }
          }
        } else if (data['data'] != null) {
          // Handle paginated response
          for (var propertyData in data['data']) {
            try {
              properties.add(Property.fromJson(propertyData));
            } catch (e) {
              // Skip invalid properties
            }
          }
        } else if (data is List) {
          // Handle direct array response
          for (var propertyData in data) {
            try {
              properties.add(Property.fromJson(propertyData));
            } catch (e) {
              // Skip invalid properties
            }
          }
        }

        setState(() {
          _properties = properties;
          _isLoading = false;
          _pmsState = _pmsState.copyWith(
            properties: properties,
            isLoading: false,
          );
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load properties';
          _isLoading = false;
          _pmsState = _pmsState.copyWith(
            isLoading: false,
            errorMessage: result['message'],
          );
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
        _pmsState = _pmsState.copyWith(
          isLoading: false,
          errorMessage: 'Network error: ${e.toString()}',
        );
      });
    }
  }

  void _openAddPropertySheet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddPropertySheet(),
      ),
    );

    if (result != null) {
      await _loadProperties();
      if (mounted && result is Property) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Property "${result.name}" added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _addProperty(Property property) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PropertiesService.createProperty(
        name: property.name,
        address: property.address,
        city: property.location.split(',')[0].trim(),
        state: property.location.split(',').length > 1 ? property.location.split(',')[1].trim() : '',
        country: property.location.split(',').length > 2 ? property.location.split(',')[2].trim() : '',
        postalCode: '', // Property model doesn't have postalCode
        phone: property.ownerPhone,
        email: property.ownerEmail,
        description: property.description,
        website: '', // Property model doesn't have website
        totalRooms: property.capacity,
        propertyType: property.type.toString().split('.').last,
      );

      if (result['success']) {
        // Refresh the properties list
        await _loadProperties();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Property "${property.name}" added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add property'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshProperties() async {
    await _loadProperties();
  }

  Future<void> _confirmAndDelete(Property property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete property?'),
        content: Text('Are you sure you want to delete "${property.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() { _isLoading = true; });
    final resp = await PropertiesService.deleteProperty(property.id);
    if (!mounted) return;
    if (resp['success'] == true) {
      await _loadProperties();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${property.name}"'), backgroundColor: Colors.green),
      );
    } else {
      setState(() { _isLoading = false; });
      final msg = (resp['message'] ?? 'Failed to delete').toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  void _viewProperty(Property property) {
    // TODO: Navigate to property details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${property.name}'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  void _editProperty(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditPropertyDetails(
          property: property,
          onPropertyUpdated: _loadProperties,
        ),
      ),
    ).then((result) {
      if (result is Property) {
        setState(() {
          final index = _properties.indexWhere((p) => p.id == result.id);
          if (index != -1) {
            _properties[index] = result;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openAddPropertySheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_business, color: Colors.white),
          label: Text(
            'Add Property',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Management',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Properties Display
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProperties,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    children: [
                      if (_isLoading)
                        Container(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                            ),
                          ),
                        )
                      else if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load properties',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshProperties,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (_properties.isEmpty)
                        EmptyState(
                          title: 'No properties found',
                          subtitle: 'Add your first property to get started',
                          icon: Icons.business_outlined,
                          onActionPressed: _openAddPropertySheet,
                          actionText: 'Add Property',
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _properties.length,
                          itemBuilder: (context, index) {
                            final property = _properties[index];
                            return PropertyCard(
                              property: property,
                              onViewPressed: () => _viewProperty(property),
                              onEditPressed: () => _editProperty(property),
                              onDeletePressed: () => _confirmAndDelete(property),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
