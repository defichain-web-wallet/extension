import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/gradient_borders.dart';

class AssetHeaderSelector extends StatefulWidget {
  final String assetCode;
  final bool isShown;

  const AssetHeaderSelector({
    Key? key,
    required this.assetCode,
    this.isShown = false,
  }) : super(key: key);

  @override
  State<AssetHeaderSelector> createState() => _AssetHeaderSelectorState();
}

class _AssetHeaderSelectorState extends State<AssetHeaderSelector>
    with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    double arrowRotateDeg = widget.isShown ? 180 : 0;

    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 6, left: 6, right: 8),
      decoration: BoxDecoration(
        color: isDarkTheme()
            ? DarkColors.assetSelectorBgColor.withOpacity(0.07)
            : LightColors.assetSelectorBgColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: widget.isShown
            ? GradientBoxBorder(
                gradient: gradientWrongMnemonicWord,
              )
            : Border.all(
                color: Colors.transparent,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: SvgPicture.asset(
              TokensHelper().getImageNameByTokenName(widget.assetCode),
            ),
          ),
          Flexible(
            child: TickerText(
              child: Text(
                widget.assetCode,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontSize: 20, height: 1.26),
              ),
            ),
          ),
          RotationTransition(
            turns: AlwaysStoppedAnimation(arrowRotateDeg / 360),
            child: SizedBox(
              width: 10,
              height: 10,
              child: SvgPicture.asset(
                'assets/icons/arrow_down.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
