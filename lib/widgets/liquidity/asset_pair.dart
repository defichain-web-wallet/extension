import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetPair extends StatefulWidget {
  final String pair;
  final double? size;
  final bool isRotate;
  final bool? isTransform;

  const AssetPair({
    Key? key,
    required this.pair,
    this.size = 24,
    this.isRotate = false,
    this.isTransform = true,
  }) : super(key: key);

  @override
  State<AssetPair> createState() => _AssetPairState();
}

class _AssetPairState extends State<AssetPair> with ThemeMixin {
  final double height = 34;
  final double width = 54;
  TokensHelper tokenHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          SvgPicture.asset(
            isDarkTheme()
                ? 'assets/asset_pair_bg_dark.svg'
                : 'assets/asset_pair_bg_light.svg',
            width: width,
            height: height,
          ),
          AssetLogo(
            assetStyle:
                tokenHelper.getAssetStyleByTokenName(widget.pair.split('-')[1]),
            size: height,
            isBorder: false,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: AssetLogo(
              assetStyle: tokenHelper
                  .getAssetStyleByTokenName(widget.pair.split('-')[1]),
              size: height,
              isBorder: false,
            ),
          )
        ],
      ),
    );
  }
}
