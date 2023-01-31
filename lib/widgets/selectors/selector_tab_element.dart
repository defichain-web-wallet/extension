import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/common/jelly_link_text.dart';
import 'package:flutter/material.dart';

class SelectorTabElement extends StatelessWidget {
  final String title;
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
                JellyLinkText(
                  child: Text(
                    title,
                    style: isSelect
                        ? headline5.copyWith(
                            fontSize: 12,
                            color: AppColors.pinkColor,
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
