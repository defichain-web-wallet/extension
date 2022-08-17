import 'package:flutter/material.dart';

class ErrorPlaceholder extends StatelessWidget {
  final String message;
  final String description;

  static const String defaultMessage = 'Oops';
  static const String defaultDescription =
      'Something went wrong. Please try later';

  const ErrorPlaceholder({
    Key? key,
    this.message = defaultMessage,
    this.description = defaultDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(200))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_outlined,
            color: Colors.red.shade500,
            size: 70,
          ),
          Padding(padding: const EdgeInsets.only(top: 24)),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .headline1!
                .apply(fontSizeFactor: 0.6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3,
            ),
          )
        ],
      ),
    );
  }
}
