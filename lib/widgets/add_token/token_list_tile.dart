import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:flutter/material.dart';

class TokenListTile extends StatefulWidget {
  final Function()? onTap;
  final bool isSelect;
  final bool isSingleSelect;
  final bool isConfirm;
  final bool isDense;
  final String tokenName;
  final String? availableTokenName;
  final double balance;
  final Widget? customContent;

  const TokenListTile({
    Key? key,
    this.onTap,
    required this.isSelect,
    this.availableTokenName,
    this.balance = 0,
    this.isSingleSelect = false,
    this.isConfirm = false,
    this.isDense = false,
    required this.tokenName,
    this.customContent,
  }) : super(key: key);

  @override
  State<TokenListTile> createState() => _TokenListTileState();
}

class _TokenListTileState extends State<TokenListTile> with ThemeMixin {
  BalancesHelper balancesHelper = BalancesHelper();

  @override
  Widget build(BuildContext context) {
    String formatBalance = balancesHelper.numberStyling(
      widget.balance,
      fixedCount: 2,
      fixed: true
    );
    return GestureDetector(
      onTap: widget.isConfirm ? null : widget.onTap,
      child: MouseRegion(
        cursor: widget.isConfirm ? MouseCursor.defer : SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(1),
          height: widget.isDense ? 58 : 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                !widget.isSelect ? AppColors.portage.withOpacity(0.12) : null,
            gradient: widget.isSelect ? gradientBottomToUpCenter : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: isDarkTheme()
                  ? DarkColors.scaffoldBgColor
                  : LightColors.scaffoldContainerBgColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme()
                    ? DarkColors.scaffoldContainerBgColor
                    : widget.isSelect
                        ? AppColors.portageBg.withOpacity(0.07)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.customContent == null)
                          Row(
                            children: [
                              SizedBox(
                                width: 11,
                              ),
                              if (tokenHelper
                                  .isPair(widget.tokenName.replaceAll('d', '')))
                                AssetPair(
                                  isBorder: false,
                                  pair: widget.tokenName,
                                  height: 16,
                                )
                              else
                                AssetLogo(
                                  size: widget.isDense ? 20 : 42,
                                  borderWidth: widget.isDense ? 0 : 5,
                                  assetStyle:
                                      tokenHelper.getAssetStyleByTokenName(
                                    widget.tokenName.replaceAll('d', ''),
                                  ),
                                ),
                              SizedBox(
                                width: 11,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.tokenName}',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                  if (widget.availableTokenName != null) ...[
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      '${widget.availableTokenName!}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.3),
                                            fontSize: 12,
                                          ),
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        if (widget.customContent != null) widget.customContent!,
                      ],
                    ),
                  ),
                  Container(
                    width: widget.isConfirm ? 150 : 38,
                    child: Column(
                      crossAxisAlignment: widget.isConfirm
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isConfirm &&
                            widget.availableTokenName != null)
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Text(
                              '$formatBalance ${widget.availableTokenName}',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        if (widget.isSingleSelect)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: widget.isSelect
                                  ? null
                                  : Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              gradient: widget.isSelect
                                  ? gradientBottomToUpCenter
                                  : null,
                            ),
                            child: Center(
                              child: Container(
                                width: widget.isSelect ? 8 : 12,
                                height: widget.isSelect ? 8 : 12,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(
                                      widget.isSelect ? 4 : 6),
                                ),
                                child: Container(
                                  width: widget.isSelect ? 8 : 12,
                                  height: widget.isSelect ? 8 : 12,
                                  decoration: BoxDecoration(
                                    color: isDarkTheme()
                                        ? DarkColors.scaffoldContainerBgColor
                                        : LightColors.scaffoldContainerBgColor,
                                    borderRadius: BorderRadius.circular(
                                        widget.isSelect ? 4 : 6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!widget.isSingleSelect && widget.isSelect)
                          DefiCheckbox(
                            callback: (val) {
                              widget.onTap!();
                            },
                            value: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
