import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/access_token_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/earn/earn_card.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen_new.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_start_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/staking/staking_card.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarnScreenWrapper extends StatefulWidget {
  final Function() loadEarnData;
  final bool isFullScreen;

  EarnScreenWrapper({
    Key? key,
    required this.loadEarnData,
    required this.isFullScreen,
  }) : super(key: key);

  @override
  State<EarnScreenWrapper> createState() => _EarnScreenWrapperState();
}

class _EarnScreenWrapperState extends State<EarnScreenWrapper> with ThemeMixin {
  final BalancesHelper balancesHelper = BalancesHelper();

  @override
  Widget build(BuildContext context) {
    String titleText = 'Earn';

    return Scaffold(
      drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
      endDrawer: widget.isFullScreen ? null : AccountDrawer(
        width: buttonSmallWidth,
      ),
      appBar: widget.isFullScreen ? null : NewMainAppBar(
        isShowLogo: false,
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 22,
          bottom: 24,
          left: 16,
          right: 16,
        ),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDarkTheme()
              ? DarkColors.drawerBgColor
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
            bottomLeft: Radius.circular(isFullScreen(context) ? 20 : 0),
            bottomRight: Radius.circular(isFullScreen(context) ? 20 : 0),
          ),
        ),
        child: Center(
          child: StretchBox(
            child: Column(
              children: [
                PageTitle(
                  title: titleText,
                  isFullScreen: widget.isFullScreen,
                ),
                SizedBox(
                  height: 19,
                ),
                StakingCard(
                  loadEarnData: widget.loadEarnData,
                  callback: stakingCallback,
                ),
                SizedBox(
                  height: 18,
                ),
                BlocBuilder<TokensCubit, TokensState>(
                  builder: (tokensContext, tokensState) {
                    return liquidityMiningCard(
                      tokensState,
                      tokensState.status == TokensStatusList.loading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget liquidityMiningCard(
    TokensState tokensState,
    bool isLoading,
  ) {
    String avaragePairsAPR =
        TokensHelper().getAprFormat(tokensState.averageAccountAPR!, false);
    return EarnCard(
      isLoading: isLoading,
      title: 'Liquidity mining',
      subTitle:
          'up to ${TokensHelper().getAprFormat(tokensState.maxAPR ?? 0, true)} APR',
      imagePath: 'assets/pair_icons/dfi_btc.png',
      firstColumnNumber: balancesHelper
          .numberStyling(tokensState.totalPairsBalance ?? 0, fixed: true),
      firstColumnAsset: 'USD',
      firstColumnSubTitle: 'Pooled',
      secondColumnNumber: avaragePairsAPR,
      secondColumnAsset: '%',
      secondColumnSubTitle: 'Portfolio APR',
      isStaking: false,
      callback: () => liquidityCallback(avaragePairsAPR),
    );
  }

  stakingCallback() async {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    if (lockCubit.checkVerifiedUser(isCheckOnlyKycStatus: true)) {
      NavigatorService.push(context, StakingScreen());
    } else {
      if (lockCubit.checkValidKycLink()) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
        await lockCubit.loadKycDetails(accountCubit.state.accounts!.first);
        await lockCubit.loadUserDetails(accountCubit.state.accounts!.first);
      }
      NavigatorService.push(context, StakingKycStartScreen());
    }
  }

  liquidityCallback(String avaragePairsAPR) {
    NavigatorService.push(
      context,
      LiquidityScreenNew(
        averageARP: avaragePairsAPR,
      ),
    );
  }
}
