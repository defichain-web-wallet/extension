import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_mobile_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dialogs/redirect_to_lock_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/custom_select_tile.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StakingNewKycProcessScreen extends StatefulWidget {
  const StakingNewKycProcessScreen({Key? key, required this.kycLink}) : super(key: key);
  final String kycLink;

  @override
  State<StakingNewKycProcessScreen> createState() =>
      _StakingNewKycProcessScreenState();
}

class _StakingNewKycProcessScreenState extends State<StakingNewKycProcessScreen>
    with ThemeMixin {
  final String titleText = 'New KYC Process';
  final String subtitleText =
      'Choose the option you prefer for verification KYC';
  final String mobileText = 'by scanning QR-code';
  final String browserText = 'manually with LOCK';

  bool isMobile = true;
  bool isBrowser = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
            return Scaffold(
              drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
              endDrawer: isFullScreen ? null : AccountDrawer(
                width: buttonSmallWidth,
              ),
              appBar: isFullScreen ? null : NewMainAppBar(
                bgColor: AppColors.viridian.withOpacity(0.16),
                isShowNetworkSelector: false,
                isShowLogo: false,
              ),
              body: Container(
                decoration:
                    BoxDecoration(color: AppColors.viridian.withOpacity(0.16)),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.only(
                        top: 32,
                        bottom: 24,
                        left: 16,
                        right: 16,
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkTheme()
                            ? DarkColors.scaffoldContainerBgColor
                            : LightColors.scaffoldContainerBgColor,
                        border: isDarkTheme()
                            ? Border.all(
                                width: 1.0,
                                color: Colors.white.withOpacity(0.05),
                              )
                            : null,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                          bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                        ),
                      ),
                      child: StretchBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'DFI Staking by LOCK',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.8),
                                      ),
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                Text(
                                  titleText,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  subtitleText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                        fontSize: 12,
                                      ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                CustomSelectTile(
                                  isSelected: isMobile,
                                  callback: () {
                                    setState(() {
                                      isMobile = true;
                                      isBrowser = false;
                                    });
                                  },
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Mobile ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 16,
                                                ),
                                          ),
                                          Text(
                                            '(recommended)',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1!
                                                      .color!
                                                      .withOpacity(0.5),
                                                ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6.2,
                                      ),
                                      Text(
                                        mobileText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                              fontSize: 12,
                                            ),
                                        softWrap: true,
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 19.2,
                                ),
                                CustomSelectTile(
                                  isSelected: isBrowser,
                                  callback: () {
                                    setState(() {
                                      isMobile = false;
                                      isBrowser = true;
                                    });
                                  },
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Browser',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                              fontSize: 16,
                                            ),
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(
                                        height: 6.2,
                                      ),
                                      Text(
                                        browserText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                              fontSize: 12,
                                            ),
                                        softWrap: true,
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            NewPrimaryButton(
                              callback: () {
                                if (isMobile) {
                                  NavigatorService.push(
                                    context,
                                    StakingKycMobileScreen(
                                      kycLink: widget.kycLink,
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    barrierColor: AppColors.tolopea.withOpacity(0.06),
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return RedirectToLockDialog(
                                        kycLink: widget.kycLink,
                                      );
                                    },
                                  );
                                }
                              },
                              title: 'Continue',
                              width: buttonSmallWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 7.17,
                            bottom: 11.77,
                            left: 3,
                            right: 12.77,
                          ),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF167156),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/staking_lock.svg',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}
