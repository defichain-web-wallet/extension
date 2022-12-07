import 'package:flutter/material.dart';

class WelcomeTextCover extends StatelessWidget {
  final String text;
  final int? wordSelectId;

  static const int defaultWordId = -1;

  const WelcomeTextCover(
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
      return Theme.of(context).textTheme.headline2!;
    }
  }
}
