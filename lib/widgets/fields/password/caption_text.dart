import 'package:flutter/material.dart';

class CaptionText extends StatelessWidget {
  final String status;
  final String? text;

  const CaptionText({
    Key? key,
    required this.status,
    this.text,
  }) : super(key: key);

  static const String defaultCaptionText = 'Must be at least 8 characters';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: (status == 'error' || status == 'success') ? 160 : 134,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: getCaptionColor(opacity: 0.08),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (status == 'error' || status == 'success')
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                status == 'error' ? Icons.clear : Icons.done,
                color: getCaptionColor(),
                size: 14,
              ),
            ),
          Text(
            text ?? defaultCaptionText,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: getCaptionColor(),
                ),
          )
        ],
      ),
    );
  }

  String getCaptionText({String text = defaultCaptionText}) {
    if (status == 'error') {
      return ' $text';
    } else {
      return text;
    }
  }

  Color getCaptionColor({double opacity = 1}) {
    if (status == 'error') {
      return Color(0xFFEE1798).withOpacity(opacity);
    } else if (status == 'success') {
      return Color(0xFF00CF21).withOpacity(opacity);
    } else {
      return Color(0xFF12052F).withOpacity(opacity);
    }
  }
}
