import 'dart:async';
import 'dart:developer';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/screens/home/widgets/home_app_bar.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  LockHelper lockHelper = LockHelper();
  GlobalKey<AccountSelectState> _selectKey = GlobalKey<AccountSelectState>();
  late Color? textColorHover;
  Timer? timer;
  String tooltipMessage = "Copy to clipboard";
  bool isShowTooltip = false;
  bool firstBuild = true;
  double x = 0.0;
  double y = 0.0;
  late String destinationAddress;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        if (firstBuild) {
          textColorHover = Theme.of(context).textTheme.headline4!.color!;
          firstBuild = !firstBuild;
        }
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (BuildContext context, state) {
            if (state.status == AccountStatusList.success) {
              if (SettingsHelper.isBitcoin()) {
                destinationAddress =
                    state.activeAccount!.bitcoinAddress!.address!;
              } else {
                destinationAddress =
                    state.activeAccount!.getActiveAddress(isChange: false);
              }
              return Scaffold(
                appBar: HomeAppBar(
                  isRefresh: false,
                  isSettingsList: false,
                  selectKey: _selectKey,
                  updateCallback: () => updateAccountDetails(context, state),
                  hideOverlay: () => hideOverlay(),
                  isShowBottom: !(txState is TransactionInitialState),
                  height: !(txState is TransactionInitialState)
                      ? ToolbarSizes.toolbarHeightWithBottom
                      : ToolbarSizes.toolbarHeight,
                  isSmall: !isFullScreen,
                ),
                body: Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  padding: const EdgeInsets.only(
                      left: 18, right: 12, top: 24, bottom: 24),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 44.0, bottom: 18),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    side: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  shadowColor: Colors.transparent,
                                  color: Colors.white,
                                  child: QrImage(
                                    data: destinationAddress,
                                    size: 170,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Address ${state.activeAccount!.name}'
                                      .toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      ?.apply(
                                        fontWeightDelta: 2,
                                        fontFamily: 'IBM Plex Sans',
                                      ),
                                ),
                              ),
                              Container(
                                child: SimpleTooltip(
                                  animationDuration: Duration(seconds: 1),
                                  show: isShowTooltip,
                                  tooltipDirection: TooltipDirection.down,
                                  arrowTipDistance: 0,
                                  arrowLength: 10,
                                  arrowBaseWidth: 20,
                                  borderWidth: 0,
                                  ballonPadding: const EdgeInsets.all(0),
                                  backgroundColor: AppTheme.pinkColor,
                                  customShadows: [
                                    const BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 0,
                                        spreadRadius: 0),
                                  ],
                                  content: Text(
                                    tooltipMessage,
                                    style: TextStyle(
                                      backgroundColor: AppTheme.pinkColor,
                                      color: Colors.white,
                                      fontSize: 12,
                                      decoration: TextDecoration.none,
                                      fontFamily: 'IBM Plex Sans',
                                    ),
                                  ),
                                  child: MouseRegion(
                                    onHover: _updateLocation,
                                    onExit: _updateLocationExit,
                                    cursor: SystemMouseCursors.click,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => copyAddress(state),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.only(left: 6),
                                            child: Text(
                                              cutAddress(destinationAddress),
                                              softWrap: false,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4
                                                  ?.apply(
                                                    color: textColorHover,
                                                    fontWeightDelta: 2,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => copyAddress(state),
                                          splashRadius: 10,
                                          iconSize: 18,
                                          icon: SvgPicture.asset(
                                              'assets/copy_icon_pink.svg'),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                width: 274,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/info_outline_pink.svg',
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 8,
                                      ),
                                      child: Text(
                                        'What can I receive with this address?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            ?.apply(
                                              fontWeightDelta: 2,
                                              fontFamily: 'IBM Plex Sans',
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: 15,
                                    bottom: 52,
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 20, right: 20, bottom: 15, top: 15),
                                  width: 274,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    'This is your personal wallet address. \nYou can use it to get DFI and DST tokens like dBTC, dETH, dTSLA & more. ',
                                    style: TextStyle(
                                      color: Color(0xFFAEB1B4),
                                      fontSize: 14,
                                      fontFamily: 'IBM Plex Sans',
                                      fontWeight: FontWeight.w300,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else
              return Container();
          },
        );
      },
    );
  }

  copyAddress(state) async {
    setState(() {
      isShowTooltip = false;
    });

    await Clipboard.setData(ClipboardData(text: destinationAddress));

    setState(() {
      tooltipMessage = "Address copied!";
      isShowTooltip = true;
    });
  }

  cutAddress(String s) {
    return s.substring(0, 16) + '...' + s.substring(26, 42);
  }

  updateAccountDetails(context, state) async {
    lockHelper.provideWithLockChecker(context, () async {
      hideOverlay();
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      if (state.status == AccountStatusList.success) {
        await accountCubit.updateAccountDetails();

        Future.delayed(const Duration(milliseconds: 1), () async {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ReceiveScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        });
      }
    });
  }

  void hideOverlay() {
    try {
      _selectKey.currentState!.hideOverlay();
    } catch (err) {
      log('error when try to hide overlay: $err');
    }
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      textColorHover = Color(0xFFFF00A3);
      isShowTooltip = true;
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  void _updateLocationExit(PointerEvent details) {
    setState(() {
      textColorHover = Theme.of(context).textTheme.headline4!.color!;
      isShowTooltip = false;
      Timer(Duration(seconds: 1), () => tooltipMessage = "Copy to clipboard");
    });
  }
}
