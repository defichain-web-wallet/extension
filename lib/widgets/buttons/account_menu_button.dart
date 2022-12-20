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
  final void Function()? callback;
  final Widget? afterTitleWidget;

  AccountMenuButton({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.callback,
    this.afterTitleWidget,
    this.isStaticBg = false,
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
          overlayColor: MaterialStateProperty.all(
            Theme.of(context).selectedRowColor.withOpacity(0.07),
          ),
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
              Container(
                width: 32,
                child: Center(
                  child: Stack(
                    children: [
                      if (!isHover)
                        SvgPicture.asset(
                          'assets/icons/setting.svg',
                          color: AppColors.darkTextColor,
                        ),
                      if (isHover)
                        SvgPicture.asset(
                          '${widget.iconPath}',
                          color: null,
                          cacheColorFilter: true,
                        ),
                      // if (!isHover)
                      //   SvgPicture.asset(
                      //     '${widget.iconPath}',
                      //     color: AppColors.darkTextColor,
                      //   ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GradientText(
                      '${widget.title}',
                      style: Theme.of(context).textTheme.headline5,
                      gradientType: GradientType.linear,
                      gradientDirection: GradientDirection.btt,
                      colors: widget.isStaticBg
                          ? [
                              AppColors.electricViolet.withOpacity(0.8),
                              AppColors.hollywoodCerise.withOpacity(0.8),
                            ]
                          : isHover
                              ? [
                                  AppColors.electricViolet.withOpacity(0.8),
                                  AppColors.hollywoodCerise.withOpacity(0.8),
                                ]
                              : [
                                  AppColors.darkTextColor,
                                  AppColors.darkTextColor,
                                ],
                    ),
                    if(widget.afterTitleWidget != null) widget.afterTitleWidget!,
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
