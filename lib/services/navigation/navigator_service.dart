import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigatorService {
  static void push(BuildContext context, Widget widget) {
    HomeCubit homeCubit = _getHomeCubit(context);

    if (_isFullScreen(context)) {
      homeCubit.updateScrollView(widget: widget);
    } else {
      Navigator.push(
        context,
        _pageRouteBuilder(widget),
      );
    }
  }

  static void pushReplacement(BuildContext context, Widget? widget) {
    HomeCubit homeCubit = _getHomeCubit(context);

    if (_isFullScreen(context)) {
      homeCubit.updateScrollView(widget: widget);
    } else {
      Navigator.pushReplacement(
        context,
        _pageRouteBuilder(widget!),
      );
    }
  }

  static PageRouteBuilder _pageRouteBuilder(Widget widget) => PageRouteBuilder(
    pageBuilder: (context, animation1, animation2) => widget,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );

  static bool _isFullScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > ScreenSizes.medium;
  }

  static HomeCubit _getHomeCubit(BuildContext context) {
   return BlocProvider.of<HomeCubit>(context);
  }
}