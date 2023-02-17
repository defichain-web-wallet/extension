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

  const StatusLogoAndTitle({
    Key? key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.isTitlePosBefore = false,
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
              child: SvgPicture.asset(
                'assets/bg_splash_dark.svg',
                color: isDarkTheme() ? null : AppColors.white,
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: (-math.pi / 180) * _logoRotateDeg,
                  child: Container(
                    height: _logoWidth,
                    width: _logoHeight,
                    child: Image(
                      image: AssetImage(
                        'assets/welcome_logo.png',
                      ),
                    ),
                  ),
                ),
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
