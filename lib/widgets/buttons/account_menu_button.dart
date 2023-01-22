import 'dart:math' as math;

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AccountMenuButton extends StatefulWidget {
  final String iconPath;
  final String title;
  final bool isStaticBg;
  final bool isHoverBackgroundEffect;
  final void Function(int index)? callback;
  final Widget? afterTitleWidget;
  final bool accountSelectMode;
  final AccountModel? account;
  final bool isLockType;
  final Color? hoverBgColor;
  final Color? hoverTextColor;

  AccountMenuButton({
    Key? key,
    required this.iconPath,
    required this.title,
    this.callback,
    this.afterTitleWidget,
    this.accountSelectMode = false,
    this.isStaticBg = false,
    this.isHoverBackgroundEffect = true,
    this.account,
    this.isLockType = false,
    this.hoverBgColor,
    this.hoverTextColor,
  }) : super(key: key);

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> with ThemeMixin {
  bool isHover = false;
  late Color _circleAccountBgColor;

  Color getRandomColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt());
  }

  @override
  void initState() {
    super.initState();
    _circleAccountBgColor = getRandomColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
              colors: widget.isStaticBg
                  ? [
                      AppColors.electricViolet.withOpacity(0.07),
                      AppColors.hollywoodCerise.withOpacity(0.07),
                    ]
                  : [
                      Colors.transparent,
                      Colors.transparent,
                    ])),
      child: ElevatedButton(
        onPressed: () {
          const int defaultAccountId = 0;
          if (widget.account == null) {
            widget.callback!(defaultAccountId);
          } else {
            widget.callback!(widget.account!.index!);
          }
        },
        onHover: (val) {
          setState(() {
            isHover = val;
          });
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.only(
              left: 4,
              right: 12,
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          overlayColor: widget.isHoverBackgroundEffect
              ? MaterialStateProperty.all(
                  widget.hoverBgColor ?? Theme.of(context).selectedRowColor.withOpacity(0.07),
                )
              : MaterialStateProperty.all<Color>(Colors.transparent),
          elevation: MaterialStateProperty.all<double>(0.0),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide.none),
          ),
        ),
        child: Container(
          child: Row(
            children: [
              if (!widget.accountSelectMode)
                Container(
                  width: 32,
                  child: Center(
                    child: Stack(
                      children: [
                        if (!isHover && !widget.isStaticBg)
                          SvgPicture.asset(
                            '${widget.iconPath}',
                            color: isDarkTheme()
                                ? AppColors.white
                                : AppColors.blackRock,
                          ),
                        if (isHover && !widget.isStaticBg)
                          SvgPicture.asset(
                            '${widget.iconPath}',
                            color: widget.hoverTextColor ??
                                AppColors.hollywoodCerise,
                            cacheColorFilter: true,
                          ),
                        if (widget.isStaticBg)
                          SvgPicture.asset(
                            '${widget.iconPath}',
                            cacheColorFilter: true,
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.accountSelectMode)
                      SizedBox(
                        width: 12,
                      ),
                    if (widget.accountSelectMode)
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: _circleAccountBgColor.withOpacity(0.16),
                        child: Text(
                          '${widget.title[0]}',
                          style: Theme.of(context)
                              .textTheme
                              .headline4!
                              .copyWith(fontSize: 11, color: AppColors.portage),
                        ),
                      ),
                    if (widget.accountSelectMode)
                      SizedBox(
                        width: 6.4,
                      ),
                    Expanded(
                      child: Text(
                        '${widget.title}',
                        style: widget.callback == null
                            ? Theme.of(context).textTheme.headline5!.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color!
                                      .withOpacity(0.5),
                                  fontSize: widget.isLockType ? 13 : 14,
                                )
                            : Theme.of(context).textTheme.headline5!.copyWith(
                                  color: isHover || widget.isStaticBg
                                      ? widget.hoverTextColor ?? AppColors.hollywoodCerise
                                      : Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!,
                                  fontSize: widget.isLockType ? 13 : 14,
                                ),
                      ),
                    ),
                    if (widget.afterTitleWidget != null)
                      widget.afterTitleWidget!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
