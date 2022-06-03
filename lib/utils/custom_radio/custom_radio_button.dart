import 'package:flutter/material.dart';
import 'base_select.dart';

class CustomRadioButton extends StatelessWidget {
  final double size;
  final bool selected;
  final Color color;
  final ValueChanged<bool>? onChange;

  const CustomRadioButton({
    Key? key,
    this.size = 10.0,
    this.selected = false,
    this.color = Colors.grey,
    this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseSelect(
      selected: selected,
      onChange: onChange,
      builder: (BuildContext context, Animation animation) {
        return Container(
          width: size,
          height: size,
          child: CustomPaint(
            painter: CustomRadioButtonPainter(
              animation: animation,
              checked: true,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class CustomRadioButtonPainter extends CustomPainter {
  final Animation animation;
  final Color color;
  final bool checked;

  CustomRadioButtonPainter({
    required this.animation,
    required this.checked,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    double transformSize = 1;
    final Offset centerBorder = Offset(size.width, size.height);
    final Offset centerInner =
        Offset((size.width) + transformSize, (size.height) + transformSize);
    final Paint borderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final Paint innerCirclePaint = Paint()
      ..strokeWidth = 2.0
      ..color = color.withOpacity(animation.value);
    canvas.drawCircle(centerBorder, size.width, borderPaint);
    canvas.drawCircle(centerInner, size.width - 5.0, innerCirclePaint);
  }

  @override
  bool shouldRepaint(CustomRadioButtonPainter oldDelegate) {
    return oldDelegate.checked != checked;
  }
}
