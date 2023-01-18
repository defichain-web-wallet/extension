import 'dart:ui';

import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';

mixin SnackBarMixin {
  // Hack for infinite showing snack bar
  static const int seconds = 3;

  showSnackBar(context, {String title = ''}) {
    SnackBar snackBar = bottomSnackBar(context,
      title: title,
      color: AppColors.txStatusDone.withOpacity(0.08),
      prefix: Icon(
        Icons.done,
        color: AppColors.txStatusDone,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  SnackBar bottomSnackBar(
    BuildContext context, {
    required Color color,
    required String title,
    String? subtitle,
    Widget? prefix,
    Widget? suffix,
    Function? onTapCallback,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      padding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      content: getSnackBarContent(
        context,
        color: color,
        title: title,
        subtitle: subtitle,
        suffix: suffix,
        prefix: prefix,
        onTapCallback: onTapCallback,
      ),
      duration: Duration(seconds: seconds),
      backgroundColor: Colors.transparent,
    );
  }

  Widget getSnackBarContent(
    BuildContext context, {
    required Color color,
    required String title,
    String? subtitle,
    Widget? prefix,
    Widget? suffix,
    Function? onTapCallback,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8.0,
          sigmaY: 8.0,
        ),
        child: GestureDetector(
          onTap: () {
            if (onTapCallback != null) {
              onTapCallback();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (prefix != null) ...[
                  prefix,
                  SizedBox(
                    width: 14,
                  ),
                ],
                Expanded(
                  child: Container(
                    height: (subtitle == null) ? 40 : 54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TickerText(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(
                            height: 4,
                          ),
                          TickerText(
                            child: Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.4)),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                if (suffix != null) ...[
                  SizedBox(
                    width: 14,
                  ),
                  suffix,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
