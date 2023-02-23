import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loader extends StatefulWidget {
  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return Center(child: SizedBox(
      height: 100,
      width: 100,
      child: Lottie.asset(
        'assets/animations/loading_jelly.json',
      ),
    ));
  }
}
