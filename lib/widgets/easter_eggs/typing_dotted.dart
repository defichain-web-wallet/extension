import 'package:flutter/material.dart';

class TypingDotted extends StatefulWidget {
  final double dotSize;
  final double spacing;

  TypingDotted({this.dotSize = 16, this.spacing = 8});

  @override
  _TypingDottedState createState() => _TypingDottedState();
}

class _TypingDottedState extends State<TypingDotted>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(vsync: this, duration: Duration(milliseconds: 1000))
      ..repeat(reverse: false);

    _animation1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _animation2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 0.6, curve: Curves.easeInOut),
      ),
    );

    _animation3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animation1,
          builder: (context, child) {
            return Opacity(
              opacity: _animation1.value,
              child: Transform.translate(
                offset: Offset(0, -widget.dotSize * 0.5 * _animation1.value),
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: widget.spacing),
        AnimatedBuilder(
          animation: _animation2,
          builder: (context, child) {
            return Opacity(
              opacity: _animation2.value,
              child: Transform.translate(
                offset: Offset(0, -widget.dotSize * 0.5 * _animation2.value),
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: widget.spacing),
        AnimatedBuilder(
          animation: _animation3,
          builder: (context, child) {
            return Opacity(
              opacity: _animation3.value,
              child: Transform.translate(
                offset: Offset(0, -widget.dotSize * 0.5 * _animation3.value),
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
