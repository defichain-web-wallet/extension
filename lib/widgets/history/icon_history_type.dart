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
          'assets/send_icon.svg',
        );
      case 'RECEIVE':
      case 'vout':
        return SvgPicture.asset(
          'assets/receive_icon.svg',
        );
      case 'PoolSwap':
        return SvgPicture.asset(
          'assets/swap_icon.svg',
        );
      case 'AddPoolLiquidity':
        return SvgPicture.asset(
          'assets/add_liquidity_icon.svg',
        );
      case 'RemovePoolLiquidity':
        return SvgPicture.asset(
          'assets/remove_liquidity_icon.svg',
        );
      default:
        return SvgPicture.asset(
          'assets/swap_icon.svg',
        );
    }
  }
}
