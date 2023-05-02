import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class SelectorTabElement extends StatelessWidget {
  final String title;
  final bool isColoredTitle;
  final bool isSelect;
  final bool isShownTestnet;
  final Function callback;
  final double? indicatorWidth;
  final bool isPaddingLeft;

  const SelectorTabElement({
    Key? key,
    required this.title,
    required this.callback,
    this.indicatorWidth,
    this.isColoredTitle = false,
    this.isSelect = false,
    this.isShownTestnet = true,
    this.isPaddingLeft = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.only(left: isPaddingLeft ? 8 : 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: isSelect
                      ? isColoredTitle
                          ? headline5.copyWith(
                              fontSize: 12,
                              color: AppColors.pinkColor,
                            )
                          : headline5.copyWith(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.headline5!.color,
                            )
                      : headline5.copyWith(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .headline5!
                              .color!
                              .withOpacity(0.3),
                        ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  width: indicatorWidth ?? 20,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: isSelect
                        ? gradientButton
                        : LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
