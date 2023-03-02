import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsListTile extends StatefulWidget {
  final String titleText;
  final String subtitleText;
  final Function()? onTap;
  final bool isComingSoon;

  const SettingsListTile({
    Key? key,
    required this.titleText,
    required this.subtitleText,
    this.isComingSoon = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<SettingsListTile> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isComingSoon ? (){} : widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 41,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.titleText,
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                                fontSize: 16,
                              ),
                        ),
                        if (widget.isComingSoon) ...[
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            '(coming soon)',
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                          ),
                        ]
                      ],
                    ),
                    Text(
                      widget.subtitleText,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .headline4!
                                .color!
                                .withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2.5,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/arrow_right.svg',
                      color: isDarkTheme()
                          ? AppColors.white.withOpacity(0.6)
                          : AppColors.darkTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
