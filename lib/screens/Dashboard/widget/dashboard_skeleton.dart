import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shimmer effect widget for skeleton loading
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFF1F5F9),
    this.highlightColor = const Color(0xFFE2E8F0),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0.0),
              end: Alignment(1.0 + _controller.value * 2, 0.0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Base skeleton box widget
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for KPI Stats Tile
class SkeletonKpiStatsTile extends StatelessWidget {
  const SkeletonKpiStatsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SkeletonBox(width: 40, height: 20, borderRadius: 4),
                  const SizedBox(height: 4),
                  const SkeletonBox(width: 50, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 1,
            height: 40,
            child: ColoredBox(color: Color(0xFFF1F5F9)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SkeletonBox(width: 40, height: 20, borderRadius: 4),
                  const SizedBox(height: 4),
                  const SkeletonBox(width: 50, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 1,
            height: 40,
            child: ColoredBox(color: Color(0xFFF1F5F9)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SkeletonBox(width: 40, height: 20, borderRadius: 4),
                  const SizedBox(height: 4),
                  const SkeletonBox(width: 50, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for Stat Tile (Financial Metrics)
class SkeletonStatTile extends StatelessWidget {
  const SkeletonStatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 80, height: 12, borderRadius: 4),
          const SizedBox(height: 6),
          const SkeletonBox(width: 100, height: 16, borderRadius: 4),
          const SizedBox(height: 10),
          Row(
            children: [
              const SkeletonBox(width: 12, height: 12, borderRadius: 2),
              const SizedBox(width: 6),
              const SkeletonBox(width: 100, height: 10, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for Counts and Occupancy Section
class SkeletonCountsAndOccupancy extends StatelessWidget {
  const SkeletonCountsAndOccupancy({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Counts Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 50, height: 10, borderRadius: 4),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonBox(width: 40, height: 10, borderRadius: 4),
                    const SkeletonBox(width: 20, height: 10, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonBox(width: 60, height: 10, borderRadius: 4),
                    const SkeletonBox(width: 20, height: 10, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SkeletonBox(width: 50, height: 10, borderRadius: 4),
                    const SkeletonBox(width: 20, height: 10, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 1,
            height: 80,
            child: ColoredBox(color: Color(0xFFF1F5F9)),
          ),
          const SizedBox(width: 20),
          // Occupancy Section
          Expanded(
            child: Column(
              children: [
                const SkeletonBox(width: 80, height: 10, borderRadius: 4),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: 0.0,
                        strokeWidth: 6,
                        backgroundColor: Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2E8F0)),
                      ),
                    ),
                    const SkeletonBox(width: 20, height: 10, borderRadius: 4),
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

/// Skeleton for Revenue Trend Card
class SkeletonRevenueTrendCard extends StatelessWidget {
  const SkeletonRevenueTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 120, height: 14, borderRadius: 4),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: SkeletonBox(width: 200, height: 100, borderRadius: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for Calendar Widget
class SkeletonCalendarWidget extends StatelessWidget {
  const SkeletonCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 100, height: 14, borderRadius: 4),
          const SizedBox(height: 16),
          // Calendar grid skeleton
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  return const SkeletonBox(width: 35, height: 35, borderRadius: 8);
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Main Dashboard Skeleton Widget
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // KPI Stats Tile
              const SkeletonKpiStatsTile(),
              const SizedBox(height: 16),
              
              // Financial Metrics (2x2 Grid)
              Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: SkeletonStatTile()),
                      SizedBox(width: 12),
                      Expanded(child: SkeletonStatTile()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Expanded(child: SkeletonStatTile()),
                      SizedBox(width: 12),
                      Expanded(child: SkeletonStatTile()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Counts and Occupancy Section
              const SkeletonCountsAndOccupancy(),
              const SizedBox(height: 16),
              
              // Revenue Trend Card
              const SkeletonRevenueTrendCard(),
              const SizedBox(height: 16),
              
              // Calendar Section
              const SkeletonCalendarWidget(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

