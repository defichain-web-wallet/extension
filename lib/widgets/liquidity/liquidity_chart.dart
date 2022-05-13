import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:flutter/material.dart';

class LiquidityChart extends StatelessWidget {
  final bool? isHidden;

  const LiquidityChart({Key? key, this.isHidden}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isHidden!) {
      return Container();
    } else {
      if (SettingsHelper.settings.theme == 'Auto') {
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? DarkChart()
            : LightChart();
      } else {
        return SettingsHelper.settings.theme == 'Light'
            ? LightChart()
            : DarkChart();
      }
    }
  }
}


class LightChart extends StatelessWidget {
  const LightChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/liquidity_chart.png',
      height: 250,
      fit: BoxFit.cover,
    );
  }
}


class DarkChart extends StatelessWidget {
  const DarkChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/liquidity_chart_dark.png',
      height: 250,
      fit: BoxFit.cover,
    );
  }
}
