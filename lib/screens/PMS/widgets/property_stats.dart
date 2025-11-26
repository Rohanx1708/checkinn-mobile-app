import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property_models.dart';

class PropertyStats extends StatelessWidget {
  final List<Property> properties;

  const PropertyStats({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculate statistics
    final totalProperties = properties.length;
    final activeProperties = properties.where((p) => p.status == PropertyStatus.active).length;
    final totalValue = properties.fold<double>(0, (sum, p) => sum + p.price);
    final averageRating = properties.isNotEmpty 
        ? properties.fold<double>(0, (sum, p) => sum + p.rating) / properties.length 
        : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Property Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Properties',
                  totalProperties.toString(),
                  Icons.business,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: _buildStatItem(
                  'Active',
                  activeProperties.toString(),
                  Icons.check_circle,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Value',
                  '\$${totalValue.toStringAsFixed(0)}',
                  Icons.attach_money,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: _buildStatItem(
                  'Avg Rating',
                  averageRating.toStringAsFixed(1),
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
