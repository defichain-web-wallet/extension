import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class MnemonicWord extends StatelessWidget with ThemeMixin {
  final int index;
  final String word;
  final bool incorrect;

  MnemonicWord({
    Key? key,
    required this.index,
    required this.word,
    this.incorrect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkTheme() ? AppColors.mirage : AppColors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
        border: incorrect ? GradientBoxBorder(
          gradient: gradientWrongMnemonicWord,
        ) : Border.all(
          color: AppColors.portage.withOpacity(0.12),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: index.toString(),
              style: Theme.of(context).textTheme.bodyText2!.apply(
                    color: AppColors.portage.withOpacity(0.5),
                  ),
            ),
            WidgetSpan(
              child: SizedBox(
                width: 6,
              ),
            ),
            TextSpan(
              text: word,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}
