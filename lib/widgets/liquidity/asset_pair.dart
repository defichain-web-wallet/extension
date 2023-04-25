import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetPair extends StatefulWidget {
  final String pair;
  final double? height;
  final bool isRotate;
  final bool? isTransform;
  final bool isBorder;

  const AssetPair({
    Key? key,
    required this.pair,
    this.height = 34,
    this.isRotate = false,
    this.isTransform = true,
    this.isBorder = true,
  }) : super(key: key);

  @override
  State<AssetPair> createState() => _AssetPairState();
}

class _AssetPairState extends State<AssetPair> with ThemeMixin {
  late double height;
  late double width;
  TokensHelper tokenHelper = TokensHelper();

  @override
  void initState() {
    height = widget.height!;
    width = 54 * height / 34;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          if (widget.isBorder)
            SvgPicture.asset(
              isDarkTheme()
                  ? 'assets/asset_pair_bg_dark.svg'
                  : 'assets/asset_pair_bg_light.svg',
              width: width,
              height: height,
            ),
          AssetLogo(
            assetStyle: tokenHelper.getAssetStyleByTokenName(
              tokenHelper.getBaseAssetName(widget.pair),
            ),
            size: height,
            isBorder: false,
            borderWidth: widget.isBorder ? 5 : 0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20 * height / 34),
            child: AssetLogo(
              assetStyle: tokenHelper.getAssetStyleByTokenName(
                tokenHelper.getQuoteAssetName(widget.pair),
              ),
              size: height,
              isBorder: false,
              borderWidth: widget.isBorder ? 5 : 0,
            ),
          )
        ],
      ),
    );
  }
}
