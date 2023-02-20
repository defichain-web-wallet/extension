import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class WelcomeTextCover extends StatelessWidget with ThemeMixin {
  final String text;
  final int? wordSelectId;

  static const int defaultWordId = -1;

  WelcomeTextCover(
    this.text, {
    Key? key,
    this.wordSelectId = defaultWordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> words = text.split(',');

    return RichText(
      text: TextSpan(
        children: List.generate(words.length, (index) {
          return TextSpan(
            text: '${words[index]}!   ',
            style: getSpecificTextStyle(context, index),
          );
        }),
      ),
    );
  }

  TextStyle getSpecificTextStyle(BuildContext context, int wordId) {
    if (wordSelectId == wordId) {
      return Theme.of(context)
          .textTheme
          .headline1!
          .apply(color: Theme.of(context).textTheme.headline1!.color);
    } else {
      if (isDarkTheme()) {
        return Theme.of(context).textTheme.headline2!.apply(
          color: AppColors.moonRaker.withOpacity(0.2),
        );
      } else {
        return Theme.of(context).textTheme.headline2!;
      }
    }
  }
}
