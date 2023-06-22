import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_new_kyc_process_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/custom_select_tile.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class StakingSelectVerificationScreen extends StatefulWidget {
  const StakingSelectVerificationScreen({Key? key}) : super(key: key);

  @override
  State<StakingSelectVerificationScreen> createState() =>
      _StakingSelectVerificationScreenState();
}

class _StakingSelectVerificationScreenState
    extends State<StakingSelectVerificationScreen> with ThemeMixin, SnackBarMixin {
  final String titleText = 'Staking';
  final String kycHandoverText = 'Transfer your KYC (Know-your-customer) data '
      'from DFX.swiss to LOCK and start staking right away.';
  final String newKycProcessText = 'New KYC (Know-your-customer) '
      'verification via LOCK. ';
  final String infoText = 'An additional KYC Process can be avoided by '
      'transferring your KYC data from DFX SA to MN IT Services LLC '
      '(Entity operating LOCK Staking) to start staking at LOCK immediately.'
      '\n\nFor this, I hereby agree to the transfer of my personal data that '
      'I have provided to DFX SA, incorporated in Switzerland, during the '
      'onboarding process to MN IT Services LLC on St. Vincent and the '
      'Grenadines for the purposes of carrying out know your customer '
      '(KYC) and anti-money-laundering (AML) procedures. I acknowledge '
      'that my personal data will be transferred to a country outside of '
      'the EU/Switzerland that is handling  data protection differently '
      'which means that my rights might not be enforceable in such country. '
      'You can withdraw your consent at any time. Please note however, '
      'that the withdrawal of your consent does not affect the lawfulness of '
      'processing based on your consent before its withdrawal. For further '
      'information please see our Privacy Notice or contact us: '
      'info@lock.space .';
  final double infoWidth = 273;
  final double infoHeight = 350;

  bool isKycHandover = true;
  bool isNewKycProcess = false;
  bool isShowInfo = false;

  DfxRequests dfxRequests = DfxRequests();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (accountContext, accountState) {
            return Scaffold(
              drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
              endDrawer: AccountDrawer(
                width: buttonSmallWidth,
              ),
              appBar: NewMainAppBar(
                bgColor: AppColors.viridian.withOpacity(0.16),
                isShowLogo: false,
                isShowNetworkSelector: false,
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
                                  height: 12.4,
                                ),
                                CustomSelectTile(
                                  isSelected: isKycHandover,
                                  callback: () {
                                    setState(() {
                                      isKycHandover = true;
                                      isNewKycProcess = false;
                                    });
                                  },
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'KYC Handover',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 16,
                                                ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isShowInfo = true;
                                              });
                                            },
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: SvgPicture.asset(
                                                'assets/icons/info_icon.svg',
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6.2,
                                      ),
                                      Text(
                                        kycHandoverText,
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
                                  isSelected: isNewKycProcess,
                                  callback: () {
                                    setState(() {
                                      isKycHandover = false;
                                      isNewKycProcess = true;
                                    });
                                  },
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'New KYC Process',
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
                                        newKycProcessText,
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
                              callback: !isShowInfo
                                  ? () async {
                                      if (isNewKycProcess) {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                StakingNewKycProcessScreen(kycLink: '',), //TODO: fix it
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                      }
                                      if (isKycHandover) {
                                        try {
                                          await dfxRequests.transferKYC(
                                              accountState
                                                  .accounts!.first.accessToken!);
                                        } catch (_) {
                                          showSnackBar('User not found');
                                        }
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                StakingScreen(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
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
                    if (isShowInfo)
                      Padding(
                        padding: const EdgeInsets.only(top: 90),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: infoWidth,
                              height: infoHeight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 7.0, sigmaY: 7.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: EdgeInsets.all(19.2),
                                        decoration: BoxDecoration(
                                          color: isDarkTheme()
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.65),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .selectedRowColor
                                                .withOpacity(0.24),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.8),
                                        ),
                                        child: Text(
                                          infoText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .color!
                                                    .withOpacity(0.8),
                                              ),
                                          softWrap: true,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 16, right: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isShowInfo = false;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .dividerColor
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
