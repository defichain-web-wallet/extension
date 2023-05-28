import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigatorService {
  static void push(BuildContext context, Widget? widget) {
    HomeCubit homeCubit = _getHomeCubit(context);

    if (_isFullScreen(context)) {
      homeCubit.updateScrollView(widget: widget);
    } else {
      _provideDefaultNavigator(context, widget);
    }
  }

  static void pushReplacement(BuildContext context, Widget? widget) {
    HomeCubit homeCubit = _getHomeCubit(context);

    if (_isFullScreen(context)) {
      homeCubit.updateScrollView(widget: widget);
    } else {
      _provideDefaultNavigator(context, widget);
    }
  }

  static void pop(BuildContext context) {
    HomeCubit homeCubit = _getHomeCubit(context);

    if (_isFullScreen(context)) {
      homeCubit.updateScrollView(widget: null);
    } else {
      Navigator.of(context).pop();
    }
  }

  static Widget _getHomeWidget() => HomeScreen(
    isLoadTokens: true,
  );

  static void _provideDefaultNavigator(BuildContext context, Widget? widget) {
    if (widget != null) {
      Navigator.push(
        context,
        _pageRouteBuilder(widget),
      );
    } else {
      Widget homeWidget = _getHomeWidget();
      Navigator.push(
        context,
        _pageRouteBuilder(homeWidget),
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