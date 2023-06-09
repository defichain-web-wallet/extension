import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/lock_staking_provider_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/staking_token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'lock_state.dart';

class LockCubit extends Cubit<LockState> {
  LockCubit() : super(LockState());

  setInitial() {
    emit(state.copyWith(
        status: LockStatusList.initial));
  }

  signUp(context, String password) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var stakingProviders = activeNetwork.getStakingProviders();
    var lockStaking = stakingProviders[0];

    await (lockStaking as LockStakingProviderModel).signUp(account, password, walletCubit.state.applicationModel!);
    await StorageService.saveApplication(walletCubit.state.applicationModel!);

    await _checkAccessKey(lockStaking, account, stakingProviders);
  }

  signIn(context, String password) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var stakingProviders = activeNetwork.getStakingProviders();
    var lockStaking = stakingProviders[0];

    await (lockStaking as LockStakingProviderModel).signIn(account, password, walletCubit.state.applicationModel!);
    await StorageService.saveApplication(walletCubit.state.applicationModel!);

    await _checkAccessKey(lockStaking, account, stakingProviders);
  }

  getAvailableBalances(context) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var balance = await activeNetwork.getAvailableBalance(account: account, token: state.stakingTokenModel!, type: TxType.send);
    emit(state.copyWith(
        availableBalance: balance
    ));
  }

  Future<bool> unstake(context, password, double amount) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var activeAccount = walletCubit.state.applicationModel!.activeAccount!;

    return state.lockStaking!.unstakeToken(activeAccount, password, state.stakingTokenModel!, state.stakingModel!, activeNetwork, amount, 'DFI', walletCubit.state.applicationModel!);
  }

  Future<TxErrorModel> stake(context, password, double amount) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var activeAccount = walletCubit.state.applicationModel!.activeAccount!;

    return state.lockStaking!.stakeToken(activeAccount, password, state.stakingTokenModel!, state.stakingModel!, activeNetwork, amount, 'DFI', walletCubit.state.applicationModel!);
  }

  init(context) async {
    emit(state.copyWith(status: LockStatusList.loading));

    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var activeAccount = walletCubit.state.applicationModel!.activeAccount!;
    var stakingProviders = activeNetwork.getStakingProviders();
    var lockStaking = stakingProviders[0];

    await _checkAccessKey(lockStaking as LockStakingProviderModel, activeAccount, stakingProviders);
  }

  _checkAccessKey(LockStakingProviderModel lockStaking, AbstractAccountModel account, List<AbstractStakingProviderModel> stakingProviders) async {
    var accessKey = lockStaking.getAccessToken(account);
    if (accessKey != null) {
      if(accessKey.isValid()){
        bool lockAccountPresent = false;
        bool isKycDone = false;
        String kycLink = '';
        StakingTokenModel? stakingTokenModel;
        StakingModel? stakingModel;

        lockAccountPresent = true;
        isKycDone = await lockStaking.isKycDone(account);

        LockStatusList status;
        stakingTokenModel = await lockStaking.getDefaultStakingToken(account);
        if (!isKycDone) {
          status = LockStatusList.neededKyc;
          kycLink = await lockStaking.getKycLink(account);
        } else {
          status = LockStatusList.success;
          stakingModel = await lockStaking.getStaking(account);
        }
        emit(state.copyWith(
          status: status,
          stakingProviders: stakingProviders,
          lockStaking: lockStaking,
          accessKey: accessKey,
          lockAccountPresent: lockAccountPresent,
          isKycDone: isKycDone,
          kycLink: kycLink,
          stakingModel: stakingModel,
          stakingTokenModel: stakingTokenModel,
          //staking lock
        ));
      } else {
        emit(state.copyWith(status: LockStatusList.expired));
      }
    } else {
      emit(state.copyWith(status: LockStatusList.notFound));
    }
  }
}
