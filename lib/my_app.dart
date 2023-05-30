import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/available_amount/available_amount_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/dex/dex_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/bloc/ramp/ramp_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/exchange/exchange_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/transaction/tx_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/screens/error_screen.dart';
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
        BlocProvider<AvailableAmountCubit>(create: (context) => AvailableAmountCubit()),
        BlocProvider<TokensCubit>(create: (context) => TokensCubit()),
        BlocProvider<DexCubit>(create: (context) => DexCubit()),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<TransactionCubit>(create: (context) => TransactionCubit()),
        BlocProvider<FiatCubit>(create: (context) => FiatCubit()),
        BlocProvider<LockCubit>(create: (context) => LockCubit()),
        BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
        BlocProvider<BitcoinCubit>(create: (context) => BitcoinCubit()),
        BlocProvider<NetworkCubit>(create: (context) => NetworkCubit()),
        BlocProvider<RampCubit>(create: (context) => RampCubit()),
        BlocProvider<WalletCubit>(create: (context) => WalletCubit()),
        BlocProvider<TxCubit>(create: (context) => TxCubit()),
        BlocProvider<ExchangeCubit>(create: (context) => ExchangeCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return ErrorScreen(errorDetails: errorDetails);
          };
          return widget!;
        },
        home: WalletChecker(),
      ),
    );
  }
}
