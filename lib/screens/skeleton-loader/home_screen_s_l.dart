import 'dart:async';

import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/skeleton_loader/skeleton_container.dart';
import 'package:defi_wallet/widgets/skeleton_loader/skeleton_token_container.dart';
import 'package:defi_wallet/widgets/toolbar/home_app_bar_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenSL extends StatefulWidget {
  Timer? timer;
  bool isDarkTheme;

  HomeScreenSL({
    Key? key,
    required this.timer,
    this.isDarkTheme = false,
  }) : super(key: key);

  @override
  State<HomeScreenSL> createState() => _HomeScreenSLState();
}

class _HomeScreenSLState extends State<HomeScreenSL> {
  Color _color = Color(0xffEDEDED);
  Color _colorDark = Color(0xff2a2929);
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);
  double actionBtnSpace = 28;

  @override
  void initState() {
    widget.timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        if (widget.isDarkTheme) {
          _colorDark = _colorDark == Color(0xff2a2929)
              ? Color(0xff3c3e42)
              : Color(0xff2a2929);
        } else {
          _color = _color == Color(0xffEDEDED)
              ? Color(0xffe8e5e5)
              : Color(0xffEDEDED);
        }
        print('${widget.timer!.isActive}');
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        return ScaffoldConstrainedBox(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < ScreenSizes.medium) {
                return Scaffold(
                  appBar: HomeAppBarSkeleton(
                    color: widget.isDarkTheme ? _colorDark : _color,
                  ),
                  body: _buildBody(),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Scaffold(
                    appBar: HomeAppBarSkeleton(
                      color: widget.isDarkTheme ? _colorDark : _color,
                      isSmall: false,
                    ),
                    body: _buildBody(isFullScreen: true),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildBody({isFullScreen = false}) {
    SkeletonContainer currencyBtn = SkeletonContainer(
      width: 40,
      height: 16,
      color: widget.isDarkTheme ? _colorDark : _color,
      borderRadius: _borderRadius,
    );
    SkeletonContainer actionBtnText = SkeletonContainer(
      width: 35,
      height: 12,
      color: widget.isDarkTheme ? _colorDark : _color,
      borderRadius: _borderRadius,
    );
    SkeletonContainer actionBtn = SkeletonContainer(
      width: 35,
      height: 35,
      color: widget.isDarkTheme ? _colorDark : _color,
      shape: BoxShape.circle,
    );
    SkeletonTokenContainer tokenContainer = SkeletonTokenContainer(
      color: widget.isDarkTheme ? _colorDark : _color,
    );

    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Center(
        child: StretchBox(
          maxWidth: ScreenSizes.medium,
          child: ListView(
            children: [
              Container(
                color: null,
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SkeletonContainer(
                            width: 105,
                            height: 16,
                            color: widget.isDarkTheme ? _colorDark : _color,
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 9),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              currencyBtn,
                              SizedBox(
                                width: 8,
                              ),
                              currencyBtn,
                              SizedBox(
                                width: 8,
                              ),
                              currencyBtn,
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SkeletonContainer(
                            width: 210,
                            height: 24,
                            color: widget.isDarkTheme ? _colorDark : _color,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                actionBtn,
                                SizedBox(width: actionBtnSpace),
                                actionBtn,
                                SizedBox(width: actionBtnSpace),
                                actionBtn,
                                SizedBox(width: actionBtnSpace),
                                actionBtn,
                                SizedBox(width: actionBtnSpace),
                                actionBtn,
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                actionBtnText,
                                SizedBox(width: actionBtnSpace),
                                actionBtnText,
                                SizedBox(width: actionBtnSpace),
                                actionBtnText,
                                SizedBox(width: actionBtnSpace),
                                actionBtnText,
                                SizedBox(width: actionBtnSpace),
                                actionBtnText,
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    tokenContainer,
                    SizedBox(
                      height: 10,
                    ),
                    tokenContainer,
                    SizedBox(
                      height: 10,
                    ),
                    tokenContainer,
                    SizedBox(
                      height: 10,
                    ),
                    tokenContainer,
                    SizedBox(
                      height: 10,
                    ),
                    tokenContainer,
                    SizedBox(
                      height: 10,
                    ),
                    tokenContainer,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
