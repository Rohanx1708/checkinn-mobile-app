import 'package:flutter/material.dart';

/// A widget that provides staggered slide-up and fade-in animation
/// for dashboard cards on page load.
class StaggeredAnimation extends StatefulWidget {
  /// The widget to animate
  final Widget child;
  
  /// Delay before starting the animation (in milliseconds)
  final int delay;
  
  /// Animation duration (in milliseconds)
  final int duration;
  
  /// Slide offset as a fraction of widget height (default: 0.05 = 5% of height)
  final double slideOffset;

  const StaggeredAnimation({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = 600,
    this.slideOffset = 0.05,
  });

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );

    // Slide up animation: starts from below (slideOffset fraction down) to original position
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset), // Start slightly below (as fraction of height)
      end: Offset.zero, // End at original position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Fade in animation: starts from transparent to fully opaque
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation after delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

