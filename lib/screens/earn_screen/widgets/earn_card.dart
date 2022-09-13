import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/small_primary_button.dart';
import 'package:flutter/material.dart';

class EarnCard extends StatefulWidget {
  final String title;
  final Widget titleWidget;
  final Widget smallTitleWidget;
  final String percent;
  final String balance;
  final String currency;
  final String status;
  final String firstBtnTitle;
  final String secondBtnTitle;
  final Function()? firstBtnCallback;
  final Function()? secondBtnCallback;
  final bool? isCheckLockFirst;
  final bool? isCheckLockSecond;
  final bool? isSmall;
  final bool isBorder;

  const EarnCard({
    Key? key,
    required this.title,
    required this.titleWidget,
    required this.smallTitleWidget,
    required this.percent,
    required this.balance,
    required this.currency,
    required this.status,
    required this.firstBtnTitle,
    required this.secondBtnTitle,
    this.firstBtnCallback,
    this.secondBtnCallback,
    this.isCheckLockFirst = true,
    this.isCheckLockSecond = true,
    this.isSmall = false,
    this.isBorder = false,
  }) : super(key: key);

  @override
  State<EarnCard> createState() => _EarnCardState();
}

class _EarnCardState extends State<EarnCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          right: 20,
          left: 20,
          bottom: 20,
        ),
        // width: 280,
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          border: Border.all(
            color: widget.isBorder ? Theme.of(context).dividerColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: widget.isSmall!
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                widget.smallTitleWidget,
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  widget.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .apply(fontWeightDelta: 2),
                                ),
                              ],
                            ),
                            Text(
                              widget.balance + ' ' + widget.currency,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .apply(fontWeightDelta: 2),
                            )
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .apply(fontWeightDelta: 2),
                            ),
                            widget.titleWidget,
                          ],
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'up to ' + widget.percent,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.isSmall!
                          ? [
                              Text(
                                widget.status,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ]
                          : [
                              Text(
                                widget.balance + ' ' + widget.currency,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              Text(
                                widget.status,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .apply(
                                      fontSizeFactor: 0.8,
                                    ),
                              ),
                            ],
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmallPrimaryButton(
                  label: widget.firstBtnTitle,
                  callback: widget.firstBtnCallback,
                  isCheckLock: widget.isCheckLockFirst,
                ),
                SizedBox(
                  width: 15,
                ),
                SmallPrimaryButton(
                  label: widget.secondBtnTitle,
                  callback: widget.secondBtnCallback,
                  isCheckLock: widget.isCheckLockSecond,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
