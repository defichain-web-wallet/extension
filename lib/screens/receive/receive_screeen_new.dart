import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/my_app.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveScreenNew extends StatefulWidget {
  const ReceiveScreenNew({Key? key}) : super(key: key);

  @override
  State<ReceiveScreenNew> createState() => _ReceiveScreenNewState();
}

class _ReceiveScreenNewState extends State<ReceiveScreenNew> with ThemeMixin {
  bool isCopied = false;
  late String address;
  String hintText =
      'This is your personal wallet address.\nYou can use it to receive DFI and DST tokens like dBTC, dETH, dTSLA & more.';
  String btcHintText = 'This is your personal wallet address.\nYou can use it to receive Bitcoin.';

  cutAddress(String s) {
    return s.substring(0, 5) + '...' + s.substring(s.length - 4, s.length);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (BuildContext context, state) {
            if (state.status == AccountStatusList.success) {
              if (SettingsHelper.isBitcoin()) {
                address = state.activeAccount!.bitcoinAddress!.address!;
              } else {
                address =
                    state.activeAccount!.getActiveAddress(isChange: false);
              }
              return Scaffold(
                drawerScrimColor: Color(0x0f180245),
                endDrawer: AccountDrawer(
                  width: buttonSmallWidth,
                ),
                appBar: NewMainAppBar(
                  isShowLogo: false,
                ),
                body: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(
                    top: 22,
                    bottom: 24,
                    left: 29,
                    right: 29,
                  ),
                  // width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkTheme()
                        ? DarkColors.scaffoldContainerBgColor
                        : LightColors.scaffoldContainerBgColor,
                    border: isDarkTheme() ? Border.all(
                      width: 1.0, color: Colors.white.withOpacity(0.05),
                    ) : null,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Receive',
                                style: headline3,
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Container(
                                width: 208,
                                height: 208,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(19.2),
                                  color: isDarkTheme() ? Colors.white : null,
                                  border: !isDarkTheme()
                                      ? Border.all(
                                          color: AppColors.lavenderPurple
                                              .withOpacity(0.32),
                                        )
                                      : null,
                                ),
                                child: QrImage(
                                  data: address,
                                  padding: EdgeInsets.all(17.7),
                                ),
                              ),
                              SizedBox(
                                height: 22,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Address',
                                    style: headline5.apply(
                                      color: Theme.of(context).textTheme.headline5!.color!
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6.4,
                                  ),
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 200),
                                    child: TickerText(
                                      child: Text(
                                        '${state.activeAccount!.name}',
                                        style: headline5.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 11),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: address));
                                    setState(() {
                                      isCopied = !isCopied;
                                    });
                                  },
                                  child: Container(
                                    width: 140,
                                    height: 43,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .selectedRowColor
                                          .withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(12.8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          cutAddress(address),
                                          style: headline5,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                            'assets/images/copy_gradient.png', width: 20, height: 20,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 12.8,
                              ),
                              Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                  Container(
                                    width: 272,
                                    height: 48,
                                    child: Text(
                                      SettingsHelper.isBitcoin() ? btcHintText : hintText,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.headline6!.apply(
                                          color: Theme.of(context).textTheme.headline6!.color!
                                              .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                  if (isCopied)
                                    Container(
                                      width: 243,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6.4),
                                        color: AppColors.malachite
                                            .withOpacity(0.08),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6.4),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 5.0, sigmaY: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.done,
                                                color: Color(0xFF00CF21),
                                                size: 24,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  'The address has been copied')
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          NewPrimaryButton(
                            width: buttonSmallWidth,
                            callback: () {
                              Navigator.pop(context);
                            },
                            titleWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Color(0xFFFCFBFE),
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Done',
                                  style:
                                      Theme.of(context).textTheme.button!.apply(
                                            color: Color(0xFFFCFBFE),
                                            fontWeightDelta: 1,
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
              );
            } else
              return Container();
          },
        );
      },
    );
  }
}
