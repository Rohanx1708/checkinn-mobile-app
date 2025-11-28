import 'package:flutter/material.dart';

/// Animation constants for list items
class ListItemAnimationConfig {
  /// Default animation duration in milliseconds (faster for scrolling)
  static const int defaultDuration = 250;
  
  /// Default stagger delay in milliseconds between items
  static const int defaultStaggerDelay = 15;
  
  /// Calculate delay for a list item based on its index
  static int getDelayForIndex(int index) => index * defaultStaggerDelay;
}

/// A widget that provides scale and fade-in animation for list items.
/// More suitable for listing screens than the dashboard staggered animation.
/// Optimized for fast scrolling performance.
class ListItemAnimation extends StatefulWidget {
  /// The widget to animate
  final Widget child;
  
  /// Delay before starting the animation (in milliseconds)
  final int delay;
  
  /// Animation duration (in milliseconds)
  final int duration;
  
  /// Scale factor at the start (default: 0.95)
  final double scaleStart;

  const ListItemAnimation({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = ListItemAnimationConfig.defaultDuration,
    this.scaleStart = 0.95,
  });

  @override
  State<ListItemAnimation> createState() => _ListItemAnimationState();
}

class _ListItemAnimationState extends State<ListItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );

    // Scale animation: starts from slightly smaller to normal size
    _scaleAnimation = Tween<double>(
      begin: widget.scaleStart,
      end: 1.0,
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

