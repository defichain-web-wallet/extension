import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:equatable/equatable.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'earn_state.dart';

class EarnCubit extends Cubit<EarnState> {
  EarnCubit() : super(EarnState());

  setInitial(context) {
    LmCubit lmCubit = BlocProvider.of<LmCubit>(context);
    lmCubit.setInitial();
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    lockCubit.setInitial();
    emit(state.copyWith(
        status: EarnStatusList.initial));
  }

  init(context) async {
    emit(state.copyWith(status: EarnStatusList.loading));
    LmCubit lmCubit = BlocProvider.of<LmCubit>(context);
    await lmCubit.init(context);

    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    await lockCubit.init(context);

    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var lmProviders = activeNetwork.getLmProviders();
    emit(state.copyWith(
      status: EarnStatusList.success,
      //liquidity
      lmProviders: lmProviders,
    ));
  }
}
