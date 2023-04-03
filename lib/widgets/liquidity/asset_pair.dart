import 'package:defi_wallet/bloc/easter_egg/easter_egg_cubit.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:defi_wallet/widgets/easter_eggs/single_easter_egg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (widget.pair == 'JLY-ESTR') ...[
            BlocBuilder<EasterEggCubit, EasterEggState>(
              builder: (context, state) {
                bool isAvailableEgg = state.eggsStatus != null &&
                    state.eggsStatus!.isCollectFifthEgg!;
                return Positioned(
                  right: 5,
                  top: 5,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      'assets/easter_eggs/empty_token.png',
                      color: !isAvailableEgg ? null : Color(0xFF696A6D),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 6,
              top: 2,
              child: SingleEasterEgg(
                index: 5,
                width: 22,
                height: 30,
              ),
            ),
          ] else ...[
            AssetLogo(
              assetStyle: tokenHelper.getAssetStyleByTokenName(
                tokenHelper.getBaseAssetName(widget.pair),
              ),
              size: height,
              isBorder: false,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: AssetLogo(
                assetStyle: tokenHelper.getAssetStyleByTokenName(
                  tokenHelper.getQuoteAssetName(widget.pair),
                ),
                size: height,
                isBorder: false,
              ),
            )
          ]
        ],
      ),
    );
  }
}
