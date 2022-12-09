import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/dex/dex_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/staking/staking_cubit.dart';
import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth/signup/secure_phrase_screen.dart';
import 'package:defi_wallet/screens/auth/signup/secure_placeholder_screen.dart';
import 'package:defi_wallet/screens/auth/congratulations_screen.dart';
import 'package:defi_wallet/screens/auth/name_account_screen.dart';
import 'package:defi_wallet/screens/ui_kit.dart';
import 'package:defi_wallet/utils/theme/theme_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/bloc/auth/auth_bloc.dart';
import 'package:defi_wallet/utils/wallet_checker.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<AddressBookCubit>(create: (context) => AddressBookCubit()),
        BlocProvider<AccountCubit>(create: (context) => AccountCubit()),
        BlocProvider<TokensCubit>(create: (context) => TokensCubit()),
        BlocProvider<DexCubit>(create: (context) => DexCubit()),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<TransactionCubit>(create: (context) => TransactionCubit()),
        BlocProvider<FiatCubit>(create: (context) => FiatCubit()),
        BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
        BlocProvider<StakingCubit>(create: (context) => StakingCubit()),
        BlocProvider<BitcoinCubit>(create: (context) => BitcoinCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ThemeChecker(
          RecoveryScreen()
        ),
      ),
    );
  }
}