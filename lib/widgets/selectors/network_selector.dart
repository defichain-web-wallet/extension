import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkSelector extends StatefulWidget {
  final void Function() onSelect;

  NetworkSelector({Key? key, required this.onSelect}) : super(key: key);

  @override
  _NetworkSelectorState createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();


  bool isShowAllNetworks = true;
  NetworkTabs activeTab = NetworkTabs.all;
  String currentNetworkItem = 'DefiChain Mainnet';

  static const List<dynamic> allNetworksList = [
    {
      'isTestnet': false,
      'value': NetworkList.defiMainnet,
      'name': 'DefiChain Mainnet',
    },
    {
      'isTestnet': true,
      'value': NetworkList.defiTestnet,
      'name': 'DefiChain Testnet',
    },
    {
      'isTestnet': false,
      'value': NetworkList.btcMainnet,
      'name': 'Bitcoin Mainnet',
    },
    {
      'isTestnet': true,
      'value': NetworkList.btcTestnet,
      'name': 'Bitcoin Testnet',
    },
    {
      'isTestnet': true,
      'value': NetworkList.defiMetaChainTestnet,
      'name': 'Defi-Meta-Chain Testnet',
    },
  ];

  final List<dynamic> tabs = [
    {'value': NetworkTabs.all, 'name': 'Show/Hide'},
    {'value': NetworkTabs.test, 'name': 'Test Networks'},
  ];

  Color getMarkColor(bool isActive) {
    if (isActive) {
      return AppColors.networkMarkColor;
    } else {
      return isDarkTheme()
          ? DarkColors.networkMarkColor
          : LightColors.networkMarkColor;
    }
  }

  void onChangeLocalSettings(NetworkList networkModel) async {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    bool isBitcoin = networkModel == NetworkList.btcMainnet ||
        networkModel == NetworkList.btcTestnet;
    late String network;
    if (networkModel == NetworkList.btcMainnet ||
        networkModel == NetworkList.defiMainnet) {
      network = 'mainnet';
    } else {
      network = 'testnet';
    }

    SettingsHelper.settings.network = network;
    SettingsHelper.settings.isBitcoin = isBitcoin;
    await settingsHelper.saveSettings();
    await accountCubit.changeNetwork(
        SettingsHelper.settings.network!,
    );
  }

  getNetworkName() {
    SettingsModel settings = SettingsHelper.settings;
    String network = settings.network!;
    if (network == 'mainnet') {
      return (settings.isBitcoin!) ? 'Bitcoin Mainnet' : 'DefiChain Mainnet';
    } else {
      return (settings.isBitcoin!) ? 'Bitcoin Testnet' : 'DefiChain Testnet';
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);
    NetworkCubit networkCubit = BlocProvider.of<NetworkCubit>(context);

    return CustomPopupMenu(
      menuOnChange: (b) => widget.onSelect(),
      child: Container(
        height: 24,
        width: 119,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(36),
        ),
        child: BlocBuilder<NetworkCubit, NetworkState>(
          builder: (context, networkState) {
            return Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF00CF21),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(
                        child: TickerText(
                          child: Text(
                            getNetworkName(),
                            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 8,
                  height: 8,
                  child: SvgPicture.asset(
                    'assets/icons/network_arrow_down.svg',
                  ),
                )
              ],
            );
          },
        ),
      ),
      menuBuilder: () => Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 4,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: ArrowPainter(),
          child: ClipPath(
            clipper: ArrowClipper(),
            child: BlocBuilder<NetworkCubit, NetworkState>(
              builder: (context, networkState) {
                var currentNetworksList =
                networkState.isShownTestnet
                    ? allNetworksList
                    : allNetworksList.where((element) => element['isTestnet']);
                return Container(
                  color: isDarkTheme()
                      ? DarkColors.networkDropdownBgColor
                      : LightColors.networkDropdownBgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: 240,
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
                                  SvgPicture.asset(
                                    'assets/icons/network_icon.svg',
                                    width: 18,
                                    height: 18,
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
                                style:
                                Theme.of(context).textTheme.headline6!.copyWith(
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
                                        if (tabs[index]['value'] ==
                                            NetworkTabs.test) {
                                          networkCubit
                                              .updateTestnetNetworksList(
                                                  !networkState.isShownTestnet);
                                        }
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
                                color:
                                Theme.of(context).dividerColor.withOpacity(0.1),
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
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        controller.hideMenu();
                                        if (item['value'] != NetworkList.defiMetaChainTestnet) {
                                          networkCubit.updateCurrentNetwork(item['value']);
                                          setState(() {
                                            currentNetworkItem = item['name'];
                                          });
                                          onChangeLocalSettings(item['value']);
                                        }
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
                                                BorderRadius.circular(8),
                                                color:
                                                getMarkColor(getNetworkName() == item['name']),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              item['name'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
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
            ),
          ),
        ),
      ),
      showArrow: false,
      barrierColor: Colors.transparent,
      pressType: PressType.singleClick,
      verticalMargin: -5,
      horizontalMargin: horizontalMargin,
      controller: controller,
    );
  }
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
