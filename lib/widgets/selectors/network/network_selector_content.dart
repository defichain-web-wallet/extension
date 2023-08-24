import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkSelectorContent extends StatelessWidget with ThemeMixin {
  final List<dynamic> tabs;
  final void Function(dynamic item) onChange;

  NetworkSelectorContent({
    super.key,
    required this.tabs,
    required this.onChange,
  });

  Color getMarkColor(bool isActive) {
    if (isActive) {
      return AppColors.networkMarkColor;
    } else {
      return isDarkTheme()
          ? DarkColors.networkMarkColor
          : LightColors.networkMarkColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkCubit networkCubit = BlocProvider.of<NetworkCubit>(context);

    return Container(
      margin: isFullScreen(context) ? null : const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          border: Border.all(
              color: isDarkTheme()
                  ? DarkColors.drawerBorderColor
                  : AppColors.appSelectorBorderColor)),
      child: CustomPaint(
        isComplex: true,
        willChange: true,
        painter: ArrowPainter(),
        child: ClipPath(
          clipper: ArrowClipper(),
          child: BlocBuilder<WalletCubit, WalletState>(
            builder: (context, walletState) {
              return BlocBuilder<NetworkCubit, NetworkState>(
                builder: (context, networkState) {
                  var account = walletState.activeAccount;
                  final currentNetworksList = account
                      .getNetworkModelList(walletState.applicationModel!)
                      .where((element) =>
                          element.networkType.isTestnet ==
                          (networkState.currentNetworkSelectorTab !=
                              NetworkTabs.all))
                      .toList();
                  return Container(
                    color: isDarkTheme()
                        ? DarkColors.networkDropdownBgColor
                        : LightColors.networkDropdownBgColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: isFullScreen(context) ? 272 : 240,
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 8,
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: Image.asset(
                                        'assets/icons/network.png',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Networks',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .apply(
                                            fontSizeDelta: 2,
                                          ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                                Text(
                                  'Jelly speaks more than one language. Select the network you want to use:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .color!
                                            .withOpacity(0.8),
                                      ),
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                                Row(
                                  children: [
                                    ...List<Widget>.generate(
                                      tabs.length,
                                      (index) => SelectorTabElement(
                                        isColoredTitle: true,
                                        title: tabs[index]['name'],
                                        callback: () {
                                          networkCubit.updateCurrentTab(
                                            tabs[index]['value'],
                                          );
                                        },
                                        isSelect: networkState
                                                .currentNetworkSelectorTab ==
                                            tabs[index]['value'],
                                        isShownTestnet:
                                            networkState.isShownTestnet,
                                        isPaddingLeft: index % 2 == 1,
                                        indicatorWidth: 60,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.1),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: currentNetworksList
                                  .map(
                                    (item) => Column(
                                      children: [
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              onChange(item);
                                            },
                                            child: Container(
                                              height: 44,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 10,
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: getMarkColor(walletState
                                                              .applicationModel!
                                                              .activeNetwork!
                                                              .networkType
                                                              .networkName ==
                                                          item.networkType
                                                              .networkName),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    item.networkType
                                                        .networkNameFormat,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline5!
                                                                  .color,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final CustomClipper<Path> clipper = ArrowClipper();

  @override
  void paint(Canvas canvas, Size size) {
    var path = clipper.getClip(size);
    Paint paint = new Paint()
      ..color = AppColors.white.withOpacity(0.04)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double startMargin = 0;

    final double s1 = height * 0.3;
    final double s2 = height * 0.7;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startMargin, 0, width - startMargin, height),
          const Radius.circular(16),
        ),
      )
      ..lineTo(startMargin, s1)
      ..lineTo(startMargin, s2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
