import 'package:flutter/material.dart';
import '../screens/Dashboard/widget/dashboard_skeleton.dart' show SkeletonBox;

/// Reusable skeleton loader components for different screen types

/// Skeleton for list item cards (bookings, leads, customers, etc.)
class SkeletonListCard extends StatelessWidget {
  final double? height;
  
  const SkeletonListCard({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 40, height: 40, borderRadius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 120, height: 14, borderRadius: 4),
                    const SizedBox(height: 8),
                    const SkeletonBox(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              const SkeletonBox(width: 60, height: 24, borderRadius: 6),
            ],
          ),
          if (height != null) ...[
            const SizedBox(height: 12),
            const SkeletonBox(width: double.infinity, height: 1, borderRadius: 0),
            const SizedBox(height: 12),
            Row(
              children: [
                const SkeletonBox(width: 100, height: 12, borderRadius: 4),
                const Spacer(),
                const SkeletonBox(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for property/room cards
class SkeletonPropertyCard extends StatelessWidget {
  const SkeletonPropertyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const SkeletonBox(
            width: double.infinity,
            height: 180,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 150, height: 18, borderRadius: 4),
                const SizedBox(height: 8),
                const SkeletonBox(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SkeletonBox(width: 60, height: 12, borderRadius: 4),
                    const SizedBox(width: 12),
                    const SkeletonBox(width: 60, height: 12, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonBox(width: 80, height: 16, borderRadius: 4),
                    const SkeletonBox(width: 60, height: 12, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for agent cards
class SkeletonAgentCard extends StatelessWidget {
  const SkeletonAgentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 60, height: 60, borderRadius: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 120, height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                const SkeletonBox(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                const SkeletonBox(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SkeletonBox(width: 24, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton for booking cards
class SkeletonBookingCard extends StatelessWidget {
  const SkeletonBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(width: 100, height: 16, borderRadius: 4),
              const SkeletonBox(width: 60, height: 20, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SkeletonBox(width: 80, height: 14, borderRadius: 4),
              const SizedBox(width: 16),
              const SkeletonBox(width: 80, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonBox(width: double.infinity, height: 1, borderRadius: 0),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(width: 100, height: 14, borderRadius: 4),
              const SkeletonBox(width: 80, height: 16, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Generic skeleton list loader
class SkeletonListLoader extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  
  const SkeletonListLoader({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: 8,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: itemBuilder,
    );
  }
}

/// Skeleton for stat cards (used in reports)
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 36, height: 36, borderRadius: 10),
            const SizedBox(height: 16),
            const SkeletonBox(width: 80, height: 20, borderRadius: 4),
            const SizedBox(height: 8),
            const SkeletonBox(width: 120, height: 16, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for reports screen main layout
class SkeletonReportsScreen extends StatelessWidget {
  const SkeletonReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
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
                      const SkeletonBox(width: 180, height: 20, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs Section Skeleton
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: List.generate(4, (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: const SkeletonBox(height: 40, borderRadius: 8),
                  ),
                )),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content Skeleton
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  // Stats Grid Skeleton
                  Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(child: SkeletonStatCard()),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonStatCard()),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: const [
                          Expanded(child: SkeletonStatCard()),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonStatCard()),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Chart Card Skeleton
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonBox(width: 200, height: 18, borderRadius: 4),
                        const SizedBox(height: 8),
                        const SkeletonBox(width: 150, height: 14, borderRadius: 4),
                        const SizedBox(height: 16),
                        const SkeletonBox(width: double.infinity, height: 200, borderRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

