import 'package:defi_wallet/widgets/buttons/back_icon_button.dart';
import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final bool isFullScreen;
  final String title;

  const PageTitle({
    Key? key,
    required this.isFullScreen,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
