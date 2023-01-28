import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconHistoryType extends StatelessWidget {
  final String? type;

  const IconHistoryType({Key? key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'SEND':
      case 'vin':
        return SvgPicture.asset(
          'assets/history/send.svg',
        );
      case 'RECEIVE':
      case 'vout':
        return SvgPicture.asset(
          'assets/history/received.svg',
        );
      case 'PoolSwap':
        return SvgPicture.asset(
          'assets/history/changed.svg',
        );
      case 'AddPoolLiquidity':
        return SvgPicture.asset(
          'assets/history/liquidity.svg',
        );
      case 'RemovePoolLiquidity':
        return SvgPicture.asset(
          'assets/history/liquidity.svg',
        );
      default:
        return SvgPicture.asset(
          'assets/history/changed.svg',
        );
    }
  }
}
