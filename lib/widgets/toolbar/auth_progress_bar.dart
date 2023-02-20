import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class AuthProgressBar extends StatelessWidget with PreferredSizeWidget {
  final double fill;
  const AuthProgressBar({Key? key, this.fill = 1.0}) : super(key: key);

  static const double progressBarHeight = 3;

  @override
  Size get preferredSize => const Size.fromHeight(progressBarHeight);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned(
          child: Container(
            width: screenWidth * fill,
            height: progressBarHeight,
            decoration: BoxDecoration(
              borderRadius: fill != 1 ? BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ) : null,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFFF00A3),
                  Color(0xFFBC00C0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          child: Container(
            color: AppColors.portage.withOpacity(0.12),
            height: progressBarHeight,
            width: screenWidth,
          ),
        ),
      ],
    );
  }
}
