import 'dart:ui';

import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';

mixin SnackBarMixin {
  SnackBar bottomShackBar(
    BuildContext context, {
    required Color color,
    required String title,
    double opacity = 0.15,
    String? subtitle,
    Widget? prefix,
    Widget? suffix,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      content: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
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
      backgroundColor: color.withOpacity(opacity),
    );
  }
}
