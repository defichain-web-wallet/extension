import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetPair extends StatefulWidget {
  final String pair;
  final double? size;
  final double width;
  final bool isRotate;
  final bool? isTransform;

  const AssetPair({
    Key? key,
    required this.pair,
    this.size = 24,
    this.width = 54,
    this.isRotate = false,
    this.isTransform = true,
  }) : super(key: key);

  @override
  State<AssetPair> createState() => _AssetPairState();
}

class _AssetPairState extends State<AssetPair> with ThemeMixin {
  TokensHelper tokenHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 34,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              isDarkTheme()
                  ? 'assets/asset_pair_bg_dark.svg'
                  : 'assets/asset_pair_bg_light.svg',
              width: widget.width,
              height: 34,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: widget.size! * 2,
              height: widget.size,
              padding: const EdgeInsets.only(left: 3),
              child: Stack(
                children: [
                  Positioned(
                    child: Image.asset(
                      tokenHelper
                          .getImagePathByTokenName(widget.pair.split('-')[0])!,
                      height: widget.size,
                      width: widget.size,
                    ),
                  ),
                  Positioned(
                    left: widget.size! - 6,
                    child: SvgPicture.asset(
                      tokenHelper
                          .getImagePathByTokenName(widget.pair.split('-')[1])!,
                      height: widget.size,
                      width: widget.size,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
