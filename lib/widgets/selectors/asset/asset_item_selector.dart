import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/common/app_radio_button.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class AssetItemSelector extends StatefulWidget {
  final void Function() onChange;
  final String assetCode;
  final String? assetName;
  final bool isActive;

  const AssetItemSelector({
    Key? key,
    required this.onChange,
    required this.assetCode,
    this.assetName,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<AssetItemSelector> createState() => _AssetItemSelectorState();
}

class _AssetItemSelectorState extends State<AssetItemSelector> {
  TokensHelper tokensHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onChange();
        },
        child: Container(
          width: 94,
          height: 82,
          padding:
              const EdgeInsets.only(left: 10, top: 10, bottom: 12, right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: widget.isActive
                ? LightColors.assetSelectedItemSelectorBgColor.withOpacity(0.07)
                : null,
            border: widget.isActive
                ? GradientBoxBorder(
                    gradient: gradientWrongMnemonicWord,
                  )
                : Border.all(
                    color: LightColors.assetItemSelectorBorderColor
                        .withOpacity(0.24),
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: SvgPicture.asset(
                      TokensHelper().getImageNameByTokenName(widget.assetCode),
                    ),
                  ),
                  Container(
                    child: AppRadioButton(
                      callback: () {
                        widget.onChange();
                      },
                      isSelect: widget.isActive,
                    ),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: TickerText(
                  child: Text(
                    tokensHelper.getTokenWithPrefix(widget.assetCode),
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontSize: 16,
                        ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: TickerText(
                  child: Text(
                    widget.assetName ?? widget.assetCode,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontSize: 10,
                          color: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .color!
                              .withOpacity(0.5),
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
