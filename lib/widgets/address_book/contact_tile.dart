import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ContactTile extends StatefulWidget {
  final String contactName;
  final String contactAddress;
  final String networkName;
  final Function()? editCallback;

  const ContactTile({
    Key? key,
    required this.contactName,
    required this.contactAddress,
    required this.networkName,
    required this.editCallback,
  }) : super(key: key);

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  bool isHoverEdit = false;

  cutAddress(String s) {
    return s.substring(0, 14) + '...' + s.substring(28, 42);
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
                AppColors.redViolet.withOpacity(0.16),
                AppColors.razzmatazz.withOpacity(0.16),
              ]),
            ),
            child: Center(
              child: GradientText(
                widget.contactName[0],
                style: headline6.copyWith(fontWeight: FontWeight.w700),
                gradientType: GradientType.linear,
                gradientDirection: GradientDirection.btt,
                colors: [
                  AppColors.electricViolet,
                  AppColors.hollywoodCerise,
                ],
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
                          color: AppColors.darkTextColor.withOpacity(0.4),
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
                      style: subtitle1.apply(
                        color: AppColors.darkTextColor.withOpacity(0.5),
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
              child: isHoverEdit
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
