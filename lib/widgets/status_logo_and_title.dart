import 'dart:math' as math;

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StatusLogoAndTitle extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isTitlePosBefore;
  final Widget? subtitleWidget;
  final bool isSuccess;
  final bool isSmall;

  const StatusLogoAndTitle({
    Key? key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.isTitlePosBefore = false,
    this.isSuccess = false,
    this.isSmall = false,
  }) : super(key: key);

  @override
  State<StatusLogoAndTitle> createState() => _StatusLogoAndTitleState();
}

class _StatusLogoAndTitleState extends State<StatusLogoAndTitle>
    with ThemeMixin {
  final double _logoWidth = 158.0;
  final double _logoHeight = 167.0;
  final double _logoRotateDeg = 17.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isTitlePosBefore)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline2!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.headline5!.color,
                    ),
              ),
              if (widget.subtitle != null) ...[
                SizedBox(
                  height: 8,
                ),
                widget.subtitleWidget ??
                    Text(
                      widget.subtitle!,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 14,
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.6),
                          ),
                    ),
                SizedBox(
                  height: 8,
                ),
              ],
            ],
          ),
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Image.asset(
                widget.isSuccess
                    ? 'assets/images/jelly_success.png'
                    : 'assets/images/jelly_oops.png',
                width: widget.isSmall ? 187 : widget.isSuccess ? 223 : 225,
                height: widget.isSmall ? 180 : widget.isSuccess ? 218 : 224,
              ),
            ),
          ],
        ),
        if (!widget.isTitlePosBefore) ...[
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline2!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.headline5!.color,
                ),
          ),
          if (widget.subtitle != null) ...[
            SizedBox(
              height: 8,
            ),
            widget.subtitleWidget ??
                Text(
                  widget.subtitle!,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .headline5!
                            .color!
                            .withOpacity(0.6),
                      ),
                ),
            SizedBox(
              height: 8,
            ),
          ],
        ],
      ],
    );
  }
}
