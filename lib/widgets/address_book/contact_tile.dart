import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ContactTile extends StatefulWidget {
  final String contactName;
  final String contactAddress;
  final String networkName;
  final Function()? editCallback;
  final bool isDialog;
  final int index;

  const ContactTile({
    Key? key,
    required this.contactName,
    required this.contactAddress,
    required this.networkName,
    required this.index,
    this.editCallback,
    this.isDialog = false,
  }) : super(key: key);

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> with ThemeMixin {
  bool isHoverEdit = false;
  late int index;

  cutAddress(String s) {
    return s.substring(0, 14) + '...' + s.substring(28, 42);
  }

  int getLastCharToInt(dynamic value) {
    String stringValue = value.toString();
    return int.parse(stringValue[stringValue.length - 1]);
  }

  @override
  void initState() {
    index = widget.index < 10 ? widget.index : getLastCharToInt(index);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(colors: [
                AppColors.accountColors[index].withOpacity(0.16),
                AppColors.accountColors[index].withOpacity(0.16),
              ]),
            ),
            child: Center(
              child: Container(
                width: 25,
                child: GradientText(
                  widget.contactName[0],
                  style: headline6.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 16),
                  gradientType: GradientType.linear,
                  gradientDirection: GradientDirection.btt,
                  colors: [
                    AppColors.accountColors[index],
                    AppColors.accountColors[index],
                  ],
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 7.6,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.contactName,
                      style: headline4.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 6.4,
                    ),
                    Container(
                      height: 17.4,
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.portage.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.networkName,
                        style: subtitle2.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 8,
                          color: isDarkTheme()
                              ? AppColors.white.withOpacity(0.4)
                              : AppColors.darkTextColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      cutAddress(widget.contactAddress),
                      style: widget.isDialog
                          ? Theme.of(context).textTheme.subtitle1!.apply(
                                fontSizeFactor: 0.9,
                                color: isDarkTheme()
                                    ? AppColors.white.withOpacity(0.5)
                                    : AppColors.darkTextColor.withOpacity(0.5),
                              )
                          : Theme.of(context).textTheme.subtitle1!.apply(
                                color: isDarkTheme()
                                    ? AppColors.white.withOpacity(0.5)
                                    : AppColors.darkTextColor.withOpacity(0.5),
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 6,
          ),
          if (widget.editCallback != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (event) {
                setState(() {
                  isHoverEdit = true;
                });
              },
              onExit: (event) {
                setState(() {
                  isHoverEdit = false;
                });
              },
              child: GestureDetector(
                onTap: widget.editCallback,
                child: isDarkTheme()
                    ? SvgPicture.asset(
                        'assets/icons/edit_gradient.svg',
                        width: 17,
                        height: 17,
                      )
                    : isHoverEdit
                        ? SvgPicture.asset(
                            'assets/icons/edit_gradient.svg',
                            width: 17,
                            height: 17,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 1.0),
                            child: SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: 16,
                              height: 16,
                            ),
                          ),
              ),
            ),
        ],
      ),
    );
  }
}
