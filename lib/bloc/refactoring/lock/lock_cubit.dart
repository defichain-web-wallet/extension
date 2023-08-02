import 'package:decimal/decimal.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/lock_staking_provider_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/staking_token_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/defichain/staking/lock_requests.dart';
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

    await (lockStaking as LockStakingProviderModel).signUp(
      account,
      password,
      walletCubit.state.applicationModel!,
      walletCubit.state.activeNetwork,
    );
    await StorageService.saveApplication(walletCubit.state.applicationModel!);

    await _checkAccessKey(context, lockStaking, account, stakingProviders);
  }

  signIn(context, String password) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var stakingProviders = activeNetwork.getStakingProviders();
    var lockStaking = stakingProviders[0];

    await (lockStaking as LockStakingProviderModel).signIn(
      account,
      password,
      walletCubit.state.applicationModel!,
      walletCubit.state.activeNetwork,
    );
    await StorageService.saveApplication(walletCubit.state.applicationModel!);

    await _checkAccessKey(context, lockStaking, account, stakingProviders);
  }

  updateRewardPercentages(List<double> values, {int index = 0}) {
    emit(state.copyWith(
      status: LockStatusList.success,
    ));
    double sum = 0;
    final stakingModel = state.stakingModel!;

    for (int i = 0; i < values.length; i++) {
      stakingModel.rewardRoutes[i].rewardPercent = values[i];
      if (stakingModel.rewardRoutes[i].label != 'Reinvest') {
        sum += values[i];
      }
    }
    try {
      Decimal reinvestPercent = Decimal.parse('1') - Decimal.parse(sum.toString());

      var reinvest = stakingModel.rewardRoutes
          .firstWhere((element) => element.label == 'Reinvest');

      reinvest.rewardPercent = reinvestPercent.toDouble();
    } catch (err) {
      print('no reinvest strategy now');
    }

    emit(state.copyWith(
      stakingModel: stakingModel,
      status: LockStatusList.success,
    ));
  }

  removeRewardRoute(int index) {
    emit(state.copyWith(
      status: LockStatusList.update,
    ));
    StakingModel stakingModel = state.stakingModel!;
    List<RewardRouteModel> routes = stakingModel.rewardRoutes!;
    routes.removeAt(index);

    List<double> rewardPercentages =
    routes.map((e) => e.rewardPercent).toList();

    emit(state.copyWith(
      status: LockStatusList.success,
      stakingModel: stakingModel,
    ));
    updateRewardPercentages(rewardPercentages);
  }

  updateRewardRoutes(
    AbstractNetworkModel network,
  ) async {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));

    List<RewardRouteModel> routes = List.from(state.stakingModel!.rewardRoutes);
    try {
      var temp = routes.firstWhere((element) => element.label == 'Reinvest');
      int index = routes.indexOf(temp);
      routes.removeAt(index);
    } catch (err) {
      print('no reinvest strategy now');
    }
    var rewardRoutesString = routes.map((e) => e.toJson()).toList();

    try {
      await LockRequests().updateRewards(
        network.stakingList[0].accessTokensMap[0]!.accessToken,
        rewardRoutesString,
        state.stakingModel!.id,
      );

      emit(state.copyWith(
        status: LockStatusList.success,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: LockStatusList.failure,
      ));
    }
  }

  updateLockRewardNewRoute({
    String? asset,
    String? address,
    String? label,
    double? percent,
    bool isComplete = false,
  }) {
    StakingModel stakingModel = state.stakingModel!;
    stakingModel.rewardRouteNew = RewardRouteModel(
      targetAsset: asset ?? stakingModel.rewardRouteNew!.targetAsset,
      label: label ?? '',
      targetBlockchain: 'DeFiChain',
      targetAddress: address ?? '',
      rewardPercent: percent ?? 0,
      id: 0,
    );

    if (isComplete) {
      emit(state.copyWith(
        status: LockStatusList.update,
      ));
      StakingModel stakingModel = state.stakingModel!;
      stakingModel.rewardRoutes = [
        ...stakingModel.rewardRoutes,
        stakingModel.rewardRouteNew!,
      ];
      emit(state.copyWith(
        status: LockStatusList.success,
        stakingModel: stakingModel,
      ));
    }
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

    await _checkAccessKey(
      context,
      lockStaking as LockStakingProviderModel,
      activeAccount,
      stakingProviders,
    );
  }

  _checkAccessKey(
    context,
    LockStakingProviderModel lockStaking,
    AbstractAccountModel account,
    List<AbstractStakingProviderModel> stakingProviders,
  ) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);

    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    final assets = await activeNetwork.getAvailableTokens();

    var accessKey = lockStaking.getAccessToken(account);
    if (accessKey != null) {
      if(!accessKey.isExpire()) {
        bool lockAccountPresent = false;
        bool isKycDone = false;
        String kycLink = '';
        StakingTokenModel? stakingTokenModel;
        StakingModel? stakingModel;

        lockAccountPresent = true;
        isKycDone = await lockStaking.isKycDone(account);

        LockStatusList status;
        stakingTokenModel = await lockStaking.getDefaultStakingToken(
          account,
          walletCubit.state.activeNetwork,
        );
        try {
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
            assets: assets,
            selectedAssets: assets.where((element) => !element.isPair && !element.isDAT && !element.isUTXO).toList(),
            stakingTokenModel: stakingTokenModel,
          ));
        } catch (err) {
          emit(state.copyWith(status: LockStatusList.expired));
        }
      } else {
        emit(state.copyWith(status: LockStatusList.expired));
      }
    } else {
      emit(state.copyWith(status: LockStatusList.notFound));
    }
  }

  updateLockAssetCategory(LockAssetCryptoCategory value) {
    late List<TokenModel> selectedAssets;

    switch (value) {
      case LockAssetCryptoCategory.Crypto:
        selectedAssets = state.assets!.where((element) => !element.isPair && !element.isDAT && !element.isUTXO).toList();
        break;
      case LockAssetCryptoCategory.Stock:
        selectedAssets = state.assets!.where((element) => !element.isPair && element.isDAT && !element.isUTXO).toList();
        break;
      case LockAssetCryptoCategory.PoolPair:
        selectedAssets = state.assets!.where((element) => element.isPair && !element.isUTXO).toList();
        break;
      default:
        selectedAssets = state.assets!.where((element) => !element.isPair && !element.isDAT && !element.isUTXO).toList();
    }
    emit(state.copyWith(
      selectedAssets: selectedAssets,
      lockActiveAssetCategory: value,
    ));
  }
}
