import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class AccountMenuButton extends StatefulWidget {
  final String iconPath;
  final String title;
  final bool isStaticBg;
  final bool isHoverBackgroundEffect;
  final void Function()? callback;
  final Widget? afterTitleWidget;
  final bool accountSelectMode;

  AccountMenuButton({
    Key? key,
    required this.iconPath,
    required this.title,
    this.callback,
    this.afterTitleWidget,
    this.accountSelectMode = false,
    this.isStaticBg = false,
    this.isHoverBackgroundEffect = true,
  }) : super(key: key);

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> {
  bool isHover = false;

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
        onPressed: widget.callback,
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
                  Theme.of(context).selectedRowColor.withOpacity(0.07),
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
                            color: AppColors.darkTextColor,
                          ),
                        if (isHover && !widget.isStaticBg)
                          SvgPicture.asset(
                            '${widget.iconPath}',
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
                        backgroundColor: AppColors.portage.withOpacity(0.16),
                        child: Text(
                          'J',
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
                      child: GradientText(
                        '${widget.title}',
                        style: Theme.of(context).textTheme.headline5,
                        gradientType: GradientType.linear,
                        gradientDirection: GradientDirection.btt,
                        colors: widget.callback == null
                            ? [
                                AppColors.darkTextColor.withOpacity(0.5),
                                AppColors.darkTextColor.withOpacity(0.5),
                              ]
                            : widget.isStaticBg
                                ? [
                                    AppColors.electricViolet.withOpacity(0.8),
                                    AppColors.hollywoodCerise.withOpacity(0.8),
                                  ]
                                : isHover
                                    ? [
                                        AppColors.electricViolet
                                            .withOpacity(0.8),
                                        AppColors.hollywoodCerise
                                            .withOpacity(0.8),
                                      ]
                                    : [
                                        AppColors.darkTextColor,
                                        AppColors.darkTextColor,
                                      ],
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
