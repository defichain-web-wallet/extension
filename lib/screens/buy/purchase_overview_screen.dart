import 'dart:async';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/fiat_helper.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class PurchaseOverviewScreen extends StatefulWidget {
  final AssetByFiatModel asset;

  const PurchaseOverviewScreen({Key? key, required this.asset})
      : super(key: key);

  @override
  _PurchaseOverviewScreenState createState() => _PurchaseOverviewScreenState();
}

class _PurchaseOverviewScreenState extends State<PurchaseOverviewScreen> {
  FiatHelper fiatHelper = FiatHelper();
  late Color? textColorHover;
  int iterator = 0;
  Timer? timer;
  String tooltipMessage = "Copy to clipboard";
  bool isShowTooltipFirst = false;
  bool isShowTooltipSecond = false;
  bool isShowTooltipThird = false;
  bool isShowTooltipFourth = false;
  double x = 0.0;
  double y = 0.0;

  @override
  Widget build(BuildContext context) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (BuildContext context, state) {
        if (iterator == 0) {
          fiatCubit.loadIbanList(state.accessToken!, widget.asset);
          iterator++;
        }
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (BuildContext context, fiatState) {
            return ScaffoldConstrainedBox(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < ScreenSizes.medium) {
                    return Scaffold(
                      appBar: MainAppBar(
                        title: 'Purchase overview',
                      ),
                      body: _buildBody(state, fiatState),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Scaffold(
                        appBar: MainAppBar(
                          title: 'Purchase overview',
                          isSmall: true,
                        ),
                        body: _buildBody(state, fiatState, isFullSize: true),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(state, fiatState, {isFullSize = false}) {
    if (fiatState.status == FiatStatusList.loading) {
      return Loader();
    } else {
      return Container(
        color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
        padding:
            const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
        child: Center(
          child: StretchBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              top: 24,
                              bottom: 10,
                            ),
                            child: Image(
                              image:
                                  AssetImage('assets/buying_crypto_logo.png'),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: 13,
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.0,
                                          color: Colors.black.withOpacity(0.1),
                                          style: BorderStyle.solid),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Exchange Service',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        'DFX Swiss AG',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.0,
                                          color: Colors.black.withOpacity(0.1),
                                          style: BorderStyle.solid),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your IBAN',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        fiatHelper.getIbanFormat(
                                            fiatState.activeIban.iban),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.0,
                                          color: Colors.black.withOpacity(0.1),
                                          style: BorderStyle.solid),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Deposit limit',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        '900 € per day',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.0,
                                          color: Colors.black.withOpacity(0.1),
                                          style: BorderStyle.solid),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Service fees',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        '${fiatState.activeIban.fee}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.0,
                                          color: Colors.black.withOpacity(0.1),
                                          style: BorderStyle.solid),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your asset',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        fiatState.activeIban.asset.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              'Payment to',
                              style:
                                  Theme.of(context).textTheme.headline6?.apply(
                                        color: AppTheme.pinkColor,
                                      ),
                            ),
                          ),
                          Container(
                            color: Theme.of(context).cardColor,
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                              bottom: 10,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.black.withOpacity(0.1),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recipient',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SimpleTooltip(
                                            animationDuration:
                                                Duration(seconds: 1),
                                            show: isShowTooltipFirst,
                                            tooltipDirection:
                                                TooltipDirection.left,
                                            arrowTipDistance: 0,
                                            arrowLength: 10,
                                            arrowBaseWidth: 20,
                                            borderWidth: 0,
                                            ballonPadding:
                                                const EdgeInsets.all(0),
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
                                                backgroundColor:
                                                    AppTheme.pinkColor,
                                                color: Colors.white,
                                                fontSize: 12,
                                                decoration: TextDecoration.none,
                                                fontFamily: 'IBM Plex Sans',
                                              ),
                                            ),
                                            child: MouseRegion(
                                              onHover: _updateLocationFirst,
                                              onExit: _updateLocationExit,
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  await Clipboard.setData(
                                                    ClipboardData(
                                                        text:
                                                            'DFX AG, Bahnhofstrasse 7, 6300 Zug, Schweiz'),
                                                  );
                                                  setState(() {
                                                    tooltipMessage = 'Copied!';
                                                  });
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          'DFX AG',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline2
                                                                  ?.apply(
                                                                    color: AppTheme
                                                                        .pinkColor,
                                                                  ),
                                                        ),
                                                        Text(
                                                          'Bahnhofstrasse 7',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline2
                                                                  ?.apply(
                                                                    color: AppTheme
                                                                        .pinkColor,
                                                                  ),
                                                        ),
                                                        Text(
                                                          '6300 Zug',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline2
                                                                  ?.apply(
                                                                    color: AppTheme
                                                                        .pinkColor,
                                                                  ),
                                                        ),
                                                        Text(
                                                          'Schweiz',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline2
                                                                  ?.apply(
                                                                    color: AppTheme
                                                                        .pinkColor,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(left: 5),
                                                      child: Icon(
                                                        Icons.copy,
                                                        color: AppTheme.pinkColor,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.black.withOpacity(0.1),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'IBAN',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      SimpleTooltip(
                                        animationDuration: Duration(seconds: 1),
                                        show: isShowTooltipSecond,
                                        tooltipDirection: TooltipDirection.left,
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
                                          onHover: _updateLocationSecond,
                                          onExit: _updateLocationExit,
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                    text:
                                                        'CH68 0857 3177 9752 0181 4'),
                                              );
                                              setState(() {
                                                tooltipMessage = 'Copied!';
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  'CH68 0857 3177 9752 0181 4',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2
                                                      ?.apply(
                                                        color:
                                                            AppTheme.pinkColor,
                                                      ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.copy,
                                                    color: AppTheme.pinkColor,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Purpose of payment',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      SimpleTooltip(
                                        animationDuration: Duration(seconds: 1),
                                        show: isShowTooltipThird,
                                        tooltipDirection: TooltipDirection.left,
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
                                          onHover: _updateLocationThird,
                                          onExit: _updateLocationExit,
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                    text: fiatState
                                                        .activeIban.bankUsage),
                                              );
                                              setState(() {
                                                tooltipMessage = 'Copied!';
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  fiatState
                                                      .activeIban.bankUsage,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2
                                                      ?.apply(
                                                        color:
                                                            AppTheme.pinkColor,
                                                      ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.copy,
                                                    color: AppTheme.pinkColor,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 34,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'SWIFT/BIC',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      SimpleTooltip(
                                        animationDuration: Duration(seconds: 1),
                                        show: isShowTooltipFourth,
                                        tooltipDirection: TooltipDirection.left,
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
                                          onHover: _updateLocationFourth,
                                          onExit: _updateLocationExit,
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(text: 'MAEBCHZZ'),
                                              );
                                              setState(() {
                                                tooltipMessage = 'Copied!';
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  'MAEBCHZZ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2
                                                      ?.apply(
                                                        color:
                                                            AppTheme.pinkColor,
                                                      ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.copy,
                                                    color: AppTheme.pinkColor,
                                                    size: 16,
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
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 16),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'Note: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2),
                                  TextSpan(
                                      text:
                                          'Make sure that your payment contains the purpose of payment specified above and is executed from the IBAN you entered!',
                                      style:
                                          Theme.of(context).textTheme.headline3)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      'Send us any amount in fiat and we send you crypto back.',
                                      softWrap: true,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 320,
                  padding: EdgeInsets.only(top: 15),
                  child: PrimaryButton(
                    label: 'Complete purchase',
                    callback: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              HomeScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  _updateLocationFirst(PointerEvent details) {
    setState(() {
      textColorHover = Color(0xFFFF00A3);
      isShowTooltipFirst = true;
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  _updateLocationSecond(PointerEvent details) {
    setState(() {
      textColorHover = Color(0xFFFF00A3);
      isShowTooltipSecond = true;
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  _updateLocationThird(PointerEvent details) {
    setState(() {
      textColorHover = Color(0xFFFF00A3);
      isShowTooltipThird = true;
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  _updateLocationFourth(PointerEvent details) {
    setState(() {
      textColorHover = Color(0xFFFF00A3);
      isShowTooltipFourth = true;
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  _updateLocationExit(PointerEvent details) {
    setState(() {
      textColorHover = Theme.of(context).textTheme.headline4!.color!;
      isShowTooltipFirst = false;
      isShowTooltipSecond = false;
      isShowTooltipThird = false;
      isShowTooltipFourth = false;
      Timer(Duration(milliseconds: 1), () => tooltipMessage = "Copy to clipboard");
    });
  }
}
