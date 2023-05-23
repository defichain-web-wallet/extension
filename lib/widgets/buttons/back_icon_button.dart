import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BackIconButton extends StatelessWidget {
  final double leftPadding;
  final double width;
  final double height;
  final bool isFullScreen;
  final void Function()? callback;

  BackIconButton({
    Key? key,
    required this.leftPadding,
    required this.width,
    required this.height,
    this.isFullScreen = false,
    this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);

    return IconButton(
      padding: EdgeInsets.only(left: leftPadding),
      icon: Container(
        width: width,
        height: height,
        child: Image.asset(
          'assets/icons/arrow.png',
        ),
      ),
      onPressed: () {
        if (callback != null) {
          callback!();
        } else {
          if (isFullScreen) {
            homeCubit.updateScrollView(widget: null);
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }
}
