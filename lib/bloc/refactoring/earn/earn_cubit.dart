import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:equatable/equatable.dart';
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
