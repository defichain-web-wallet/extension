import 'package:defi_wallet/helpers/logo_helper.dart';
import 'package:defi_wallet/widgets/skeleton_loader/skeleton_container.dart';
import 'package:flutter/material.dart';

class HomeAppBarSkeleton extends StatefulWidget implements PreferredSizeWidget {
  static const double leadingWidth = 120;
  static const double toolbarHeight = 55;
  static const double accountSelectSmallHeight = 170;
  static const double accountSelectMediumHeight = 270;

  final double height;
  final bool isShowBottom;
  final bool isSmall;
  final bool isSettingsList;
  final bool isRefresh;
  final Color color;

  HomeAppBarSkeleton({
    Key? key,
    this.height = toolbarHeight,
    this.isShowBottom = false,
    this.isSmall = true,
    this.isSettingsList = true,
    this.isRefresh = true,
    required this.color,
  }) : super(key: key);

  @override
  State<HomeAppBarSkeleton> createState() => _HomeAppBarSkeletonState();

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }
}

class _HomeAppBarSkeletonState extends State<HomeAppBarSkeleton> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      shape: widget.isSmall
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
      toolbarHeight: HomeAppBarSkeleton.toolbarHeight,
      leadingWidth: HomeAppBarSkeleton.leadingWidth,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: widget.isSmall
          ? Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SkeletonContainer(
                    width: HomeAppBarSkeleton.accountSelectSmallHeight,
                    height: 38,
                    color: widget.color,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 117,
                ),
                SkeletonContainer(
                  width: HomeAppBarSkeleton.accountSelectMediumHeight,
                  height: 38,
                  color: widget.color,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                SizedBox(
                  width: 70,
                ),
              ],
            ),
      // actions: [
      //     widget.isSmall
      //         ? Padding(
      //             padding: const EdgeInsets.only(right: 2.0),
      //             child: SkeletonContainer(
      //               width: 34,
      //               height: 34,
      //               shape: BoxShape.circle,
      //               color: widget.color,
      //             ),
      //           )
      //         : Container(
      //             width: widget.isRefresh ? 0 : 65,
      //             padding: const EdgeInsets.all(0),
      //             margin: EdgeInsets.all(0),
      //           ),
      //     widget.isRefresh
      //         ? Padding(
      //             padding: const EdgeInsets.only(right: 2.0),
      //             child: SkeletonContainer(
      //               width: 34,
      //               height: 34,
      //               shape: BoxShape.circle,
      //               color: widget.color,
      //             ),
      //           )
      //         : Container(),
      //     Padding(
      //       padding: EdgeInsets.only(right: 6),
      //       child: SkeletonContainer(
      //         width: 34,
      //         height: 34,
      //         shape: BoxShape.circle,
      //         color: widget.color,
      //       ),
      //     ),
      //
      // ],
    );
  }
}
