import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/screens/earn/eaern_screen_wrapper.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({Key? key}) : super(key: key);

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  BalancesHelper balancesHelper = BalancesHelper();


  @override
  void initState() {
    super.initState();
    loadEarnData();
  }

  loadEarnData() {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    tokensCubit.calculateEarnPage(context);
    if (isDfxAccessTokenIsEmpty()) {
      fiatCubit.loadUserDetails(accountCubit.state.accounts!.first);
    }

    if (isLockAccessTokenIsEmpty()) {
      lockCubit.loadStakingDetails(
        accountCubit.state.accounts!.first,
        needKycDetails: true,
        needUserDetails: true,
      );
    }
  }

  bool isDfxAccessTokenIsEmpty() {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    return accountCubit.state.accounts!.first.accessToken != null &&
        accountCubit.state.accounts!.first.accessToken!.isNotEmpty;
  }

  bool isLockAccessTokenIsEmpty() {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    return accountCubit.state.accounts!.first.lockAccessToken != null &&
        accountCubit.state.accounts!.first.lockAccessToken!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return EarnScreenWrapper(
          loadEarnData: loadEarnData,
        );
      },
    );
  }
}
