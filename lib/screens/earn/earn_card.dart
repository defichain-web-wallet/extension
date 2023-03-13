import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletons/skeletons.dart';

class EarnCard extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final String? imagePath;
  final String? errorMessage;
  final void Function()? callback;
  final String? firstColumnNumber;
  final String? firstColumnAsset;
  final String? firstColumnSubTitle;
  final String? secondColumnNumber;
  final String? secondColumnAsset;
  final String? secondColumnSubTitle;
  final bool isStaking;
  final bool isLoading;
  final bool needUpdateAccessToken;

  const EarnCard({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.imagePath,
    required this.firstColumnNumber,
    required this.firstColumnAsset,
    required this.firstColumnSubTitle,
    this.secondColumnNumber,
    this.secondColumnAsset,
    this.secondColumnSubTitle,
    required this.isStaking,
    required this.callback,
    required this.isLoading,
    this.errorMessage = '',
    this.needUpdateAccessToken = false,
  }) : super(key: key);

  @override
  State<EarnCard> createState() => _EarnCardState();
}

class _EarnCardState extends State<EarnCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.callback!(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 129,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.portageBg.withOpacity(0.24),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        child: Image.asset(widget.imagePath!),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title!,
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 16,
                                    ),
                          ),
                          if (widget.needUpdateAccessToken)
                            Text(
                              widget.errorMessage!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: Colors.red,
                                  ),
                            )
                          else
                            widget.isLoading
                              ? SkeletonLine(
                                  style: SkeletonLineStyle(
                                      padding: EdgeInsets.only(
                                          top: 1),
                                      height: 10,
                                      width: 64,
                                      borderRadius: BorderRadius.circular(8)),
                                )
                              : Text(
                                  widget.subTitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.3),
                                      ),
                                ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!widget.needUpdateAccessToken) ...[
                              widget.isLoading
                                  ? SkeletonLine(
                                      style: SkeletonLineStyle(
                                          padding: EdgeInsets.only(
                                              top: 4, bottom: 3),
                                          height: 20,
                                          width: 64,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          widget.firstColumnNumber!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                fontSize: 20,
                                              ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 2.0),
                                          child: Text(
                                            widget.firstColumnAsset!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(
                                                  fontSize: 13,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                              Text(
                                widget.firstColumnSubTitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      if (!widget.isStaking)
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!widget.needUpdateAccessToken)
                                widget.isLoading
                                    ? SkeletonLine(
                                  style: SkeletonLineStyle(
                                      padding: EdgeInsets.only(
                                          top: 4, bottom: 3),
                                      height: 20,
                                      width: 64,
                                      borderRadius: BorderRadius.circular(8)),
                                )
                                    :Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.secondColumnNumber!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                        fontSize: 20,
                                        color: AppColors.malachite,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2.0),
                                      child: Text(
                                        widget.secondColumnAsset!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .copyWith(
                                          fontSize: 13,
                                          color: AppColors.malachite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              Text(
                                widget.secondColumnSubTitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                              ),
                            ],
                          ),
                        )
                    ],
                  )
                ],
              ),
            ),
            if (widget.isStaking)
              Padding(
                padding: const EdgeInsets.only(right: 1, top: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 9,
                        top: 11,
                        right: 13,
                        bottom: 13,
                      ),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF167156),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(11),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/staking_lock.svg'),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
