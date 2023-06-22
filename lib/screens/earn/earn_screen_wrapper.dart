import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/earn/earn_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/access_token_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/earn/earn_card.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen_new.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_start_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/staking/staking_card.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarnScreenWrapper extends StatefulWidget {
  // final Function() loadEarnData;

  EarnScreenWrapper({
    Key? key,
    // required this.loadEarnData,
  }) : super(key: key);

  @override
  State<EarnScreenWrapper> createState() => _EarnScreenWrapperState();
}

class _EarnScreenWrapperState extends State<EarnScreenWrapper> with ThemeMixin {
  final BalancesHelper balancesHelper = BalancesHelper();

  @override
  void initState() {
    EarnCubit earnCubit = BlocProvider.of<EarnCubit>(context);
    earnCubit.setInitial(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String titleText = 'Earn';

    return Scaffold(
      drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
      endDrawer: AccountDrawer(
        width: accountDrawerWidth,
      ),
      appBar: NewMainAppBar(
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
          ),
        ),
        child: Center(
          child: StretchBox(
            child: BlocBuilder<EarnCubit, EarnState>(
              builder: (earnContext, earnState) {
                EarnCubit earnCubit = BlocProvider.of<EarnCubit>(context);
                if(earnState.status == EarnStatusList.loading || earnState.status == EarnStatusList.initial){
                  if(earnState.status == EarnStatusList.initial){
                    earnCubit.init(context);
                  }
                  return Loader();
                }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            titleText,
                            style:
                            Theme
                                .of(context)
                                .textTheme
                                .headline3!
                                .copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 19,
                      ),
                      StakingCard(
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      liquidityMiningCard(
                        earnState.status == EarnStatusList.loading,
                      ),
                    ],
                  );
                }
            ),
          ),
        ),
      ),
    );
  }

  Widget liquidityMiningCard(
    bool isLoading,
  ) {
    LmState lmState = BlocProvider.of<LmCubit>(context).state;
    return EarnCard(
      isLoading: isLoading,
      title: 'Liquidity mining',
      subTitle:
          'up to ${lmState.maxApr} APR',
      imagePath: 'assets/pair_icons/dfi_btc.png',
      //TODO: add fiat value
      // firstColumnNumber: balancesHelper
      //     .numberStyling(tokensState.totalPairsBalance ?? 0, fixed: true),
      firstColumnNumber: "0",
      firstColumnAsset: 'USD',
      firstColumnSubTitle: 'Pooled',
      secondColumnNumber: lmState.averageApr,
      secondColumnAsset: '%',
      secondColumnSubTitle: 'Portfolio APR',
      isStaking: false,
      callback: () => liquidityCallback(),
    );
  }


  liquidityCallback() {
    Widget redirectTo = LiquidityScreenNew();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => redirectTo,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
