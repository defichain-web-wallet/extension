import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetIcon extends StatelessWidget {
  final String url;
  final Color color;

  AssetIcon({
    Key? key,
    required this.url,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          width: 5,
          color: color.withOpacity(0.16),
        ),
      ),
      child: SvgPicture.asset(url),
    );
  }
}
