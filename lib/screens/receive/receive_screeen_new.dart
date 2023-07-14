import 'dart:ui';

import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveScreenNew extends StatefulWidget {
  const ReceiveScreenNew({Key? key}) : super(key: key);

  @override
  State<ReceiveScreenNew> createState() => _ReceiveScreenNewState();
}

class _ReceiveScreenNewState extends State<ReceiveScreenNew> with ThemeMixin {
  bool isCopied = false;
  String hintText =
      'This is your personal wallet address.\nYou can use it to receive DFI and DST tokens like dBTC, dETH, dTSLA & more.';
  String btcHintText = 'This is your personal wallet address.\nYou can use it to receive Bitcoin.';

  cutAddress(String s, {int range = 5}) {
    return s.substring(0, range) +
        '...' +
        s.substring(
          s.length - (range - 1),
          s.length,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (BuildContext context, state) {
            if (state.status == WalletStatusList.success) {
              return Scaffold(
                drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                endDrawer: isFullScreen ? null : AccountDrawer(
                  width: buttonSmallWidth,
                ),
                appBar: isFullScreen ? null : NewMainAppBar(
                  isShowLogo: false,
                ),
                body: Container(
                  padding: EdgeInsets.only(
                    top: 22,
                    bottom: 22,
                    left: 16,
                    right: 16,
                  ),
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
                      bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                      bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                    ),
                  ),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              PageTitle(
                                title: 'Receive',
                                isFullScreen: isFullScreen,
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
                                child: QrImageView(
                                  data: state.activeAddress,
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
                                      isSpecialDuration: true,
                                      child: Text(
                                        state.activeAccount.name, //TODO: add account name
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
                                        ClipboardData(text: state.activeAddress));
                                    setState(() {
                                      isCopied = !isCopied;
                                    });
                                  },
                                  child: Container(
                                    width: isFullScreen ? 382 : 140,
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
                                          isFullScreen
                                              ? state.activeAddress
                                              : cutAddress(state.activeAddress),
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
                              NavigatorService.pop(context);
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
