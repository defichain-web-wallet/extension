import 'package:flutter/material.dart';

class JellyCustomAnimation extends StatefulWidget {
  final Offset begin;
  final Offset end;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration delayed;

  JellyCustomAnimation({
    required this.begin,
    required this.end,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delayed = const Duration(milliseconds: 0),
    this.curve = Curves.easeInOut,
  });

  @override
  _JellyCustomAnimationState createState() => _JellyCustomAnimationState();
}

class _JellyCustomAnimationState extends State<JellyCustomAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: _animation.value,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
