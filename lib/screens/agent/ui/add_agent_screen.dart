import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/common_app_bar.dart';
import '../models/agent_model.dart';

class AddAgentScreen extends StatefulWidget {
  const AddAgentScreen({super.key});

  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveAgent() {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty || _companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter agent name and company'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newAgent = Agent(
      name: _nameController.text.trim(),
      status: _selectedStatus,
      company: _companyController.text.trim(),
      photoUrl: "https://via.placeholder.com/150",
      mobile: _mobileController.text.trim(),
      altMobile: _altMobileController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    Navigator.of(context).pop(newAgent);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.withBackButton(
        title: 'Add New Agent',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              _buildFieldLabel('Agent Name *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'Enter agent name',
                icon: Icons.person,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Agent name is required' : null,
              ),
              const SizedBox(height: 16),

              // Company Field
              _buildFieldLabel('Company *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _companyController,
                hintText: 'Enter company name',
                icon: Icons.business,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Company name is required' : null,
              ),
              const SizedBox(height: 16),

              // Status Field
              _buildFieldLabel('Status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1F2937)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1F2937), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.flag, color: Color(0xFF1F2937)),
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1F2937)),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedStatus = v);
                },
              ),
              const SizedBox(height: 16),

              // Mobile Field
              _buildFieldLabel('Mobile Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _mobileController,
                hintText: 'Enter mobile number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Alt Mobile Field
              _buildFieldLabel('Alternate Mobile'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _altMobileController,
                hintText: 'Enter alternate mobile',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildFieldLabel('Email Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(v)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address Field
              _buildFieldLabel('Address'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressController,
                hintText: 'Enter address',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1F2937),
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveAgent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Save Agent',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF1F2937)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F2937), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF9CA3AF),
          fontSize: 14,
        ),
      ),
    );
  }
}

