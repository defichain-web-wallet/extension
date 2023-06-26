import 'package:defi_wallet/widgets/buttons/back_icon_button.dart';
import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String title;
  final bool isCenterAlign;
  final bool isFullScreen;

  const PageTitle({
    Key? key,
    required this.title,
    required this.isFullScreen,
    this.isCenterAlign = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCenterAlign) {
      return Stack(
        children: [
          if (isFullScreen)
            Positioned(
              child: Align(
                alignment: Alignment.centerLeft,
                child: BackIconButton(
                  leftPadding: 2,
                  width: 14,
                  height: 14,
                  isFullScreen: isFullScreen,
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          if (isFullScreen)
            BackIconButton(
              leftPadding: 2,
              width: 14,
              height: 14,
              isFullScreen: isFullScreen,
            ),
          Text(
            title,
            style: Theme.of(context).textTheme.headline3,
          ),
        ],
      );
    }
  }
}
