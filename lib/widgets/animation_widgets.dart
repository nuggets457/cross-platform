import 'package:flutter/material.dart';

/// Simple fade-in animation with optional upward slide
class FadeInUp extends StatefulWidget {
  const FadeInUp({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 600),
    this.delay = 0,
  });

  final Widget child;
  final bool enabled;
  final Duration duration;
  final int delay; // milliseconds

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.enabled && widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    } else if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.animateTo(1.0, duration: Duration.zero);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Simple scale-in animation
class ScaleIn extends StatefulWidget {
  const ScaleIn({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 400),
    this.delay = 0,
  });

  final Widget child;
  final bool enabled;
  final Duration duration;
  final int delay; // milliseconds

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.enabled && widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    } else if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.animateTo(1.0, duration: Duration.zero);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Interactive scale on tap/hover
class InteractiveScale extends StatefulWidget {
  const InteractiveScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.onTap,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<InteractiveScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.98).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
/// Scroll-based scale animation - items grow when centered, shrink when scrolling away
/// Perfect for gallery images and featured cards
class ScrollScaleAnimation extends StatelessWidget {
  const ScrollScaleAnimation({
    super.key,
    required this.child,
    required this.scrollController,
    this.minScale = 0.85,
    this.maxScale = 1.1,
  });

  final Widget child;
  final ScrollController scrollController;
  final double minScale; // Scale when scrolled away
  final double maxScale; // Scale when centered

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        // Calculate scroll offset and convert to scale factor
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        
        // Scale ranges from minScale to maxScale based on scroll position
        final scaleFactor = maxScale - (offset / 500).clamp(0, maxScale - minScale);
        final finalScale = scaleFactor.clamp(minScale, maxScale);

        return Transform.scale(
          scale: finalScale,
          child: child,
        );
      },
    );
  }
}