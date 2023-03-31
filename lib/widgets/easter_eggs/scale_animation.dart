import 'package:flutter/material.dart';

class ScaleAnimation extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final Widget child;

  ScaleAnimation({required this.width, required this.height, required this.duration, required this.child});

  @override
  _ScaleAnimationState createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _animation.value,
      child: AnimatedContainer(
          duration: widget.duration,
          width: widget.width * _animation.value,
          height: widget.height * _animation.value,
          child: widget.child,// ваш виджет здесь
      ),
    );
  }
}
