import 'package:flutter/material.dart';

class SkeletonContainer extends StatefulWidget {
  BorderRadiusGeometry? borderRadius;
  BoxShape? shape;
  Color? color;
  double? width;
  double? height;

  SkeletonContainer({
    Key? key,
    this.borderRadius,
    this.shape,
    this.color,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: widget.width == null ? double.infinity : widget.width,
      height: widget.height == null ? double.infinity : widget.height,
      decoration: BoxDecoration(
        shape: widget.shape == null ? BoxShape.rectangle : widget.shape!,
        color: widget.color,
        borderRadius: widget.borderRadius,
      ),
      duration: const Duration(milliseconds: 500),
      // Provide an optional curve to make the animation feel smoother.
      curve: Curves.fastOutSlowIn,
    );
  }
}
