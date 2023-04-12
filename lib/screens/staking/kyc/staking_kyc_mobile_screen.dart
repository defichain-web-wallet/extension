import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StakingKycMobileScreen extends StatefulWidget {
  final String kycLink;

  const StakingKycMobileScreen({
    Key? key,
    required this.kycLink,
  }) : super(key: key);

  @override
  State<StakingKycMobileScreen> createState() => _StakingKycMobileScreenState();
}

class _StakingKycMobileScreenState extends State<StakingKycMobileScreen>
    with ThemeMixin {
  final String titleText = 'QR-code';
  final String subtitleText = 'Scan QR-code with your Mobile to verificate KYC';

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
                              height: 32,
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
                                data: widget.kycLink,
                                padding: EdgeInsets.all(17.7),
                              ),
                            ),
                          ],
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
