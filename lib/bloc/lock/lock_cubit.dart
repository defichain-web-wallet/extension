import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/lock_analytics_model.dart';
import 'package:defi_wallet/models/lock_asset_model.dart';
import 'package:defi_wallet/models/lock_balance_model.dart';
import 'package:defi_wallet/models/lock_reward_routes_model.dart';
import 'package:defi_wallet/models/lock_staking_model.dart';
import 'package:defi_wallet/models/lock_user_model.dart';
import 'package:defi_wallet/requests/lock_requests.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:equatable/equatable.dart';

part 'lock_state.dart';

class LockCubit extends Cubit<LockState> {
  LockCubit() : super(LockState());

  LockRequests lockRequests = LockRequests();
  TransactionService transactionService = TransactionService();
  AccountState accountState = AccountState();

  setLoadingState() {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));
  }

  updateErrorMessage(String errorString) {
    emit(state.copyWith(
      errorMessage: errorString,
    ));
  }

  updateLockStrategy(LockStrategyList lockStrategy, AccountModel account) {
    emit(state.copyWith(
      lockStrategy: lockStrategy,
    ));
    loadStakingDetails(account, needKycDetails: true);
  }

  updateLockAssetCategory(
    LockAssetCryptoCategory value, {
    List<LockAssetModel>? list,
  }) {
    List<LockAssetModel> sourceAssets = list ?? state.lockAssets;

    late List<LockAssetModel> assets;
    late String targetCategory;

    switch (value) {
      case LockAssetCryptoCategory.Crypto:
        targetCategory = LockAssetCryptoCategory.Crypto.toString();
        break;
      case LockAssetCryptoCategory.Stock:
        targetCategory = LockAssetCryptoCategory.Stock.toString();
        break;
      case LockAssetCryptoCategory.PoolPair:
        targetCategory = LockAssetCryptoCategory.PoolPair.toString();
        break;
      default:
        targetCategory = LockAssetCryptoCategory.PoolPair.toString();
    }

    if (value == LockAssetCryptoCategory.Crypto) {
      assets = sourceAssets
          .where((el) => el.category == targetCategory && el.type != "Coin")
          .toList();
      // TODO: move here script for swap items in array to /utils
      var temp = assets.firstWhere((element) => element.name == 'DFI');
      int index = assets.indexOf(temp);
      LockAssetModel element = assets.removeAt(index);
      assets.insert(0, element);
    } else {
      assets =
          sourceAssets.where((el) => el.category == targetCategory).toList();
    }
    emit(state.copyWith(
      assetsByCategories: assets,
      lockActiveAssetCategory: value,
      lockRewardNewRoute: LockRewardRoutesModel(
        targetAsset: assets[0].name,
      ),
    ));
  }

  updateLockRewardNewRoute({
    String? asset,
    String? address,
    String? label,
    double? percent,
    bool isComplete = false,
  }) {
    LockRewardRoutesModel reward = state.lockRewardNewRoute!;
    emit(state.copyWith(
      lockRewardNewRoute: LockRewardRoutesModel(
        targetAsset: asset ?? reward.targetAsset,
        targetAddress: address ?? reward.targetAddress,
        label: label ?? reward.label,
        targetBlockchain: 'DeFiChain',
        rewardPercent: percent ?? reward.rewardPercent,
        id: 0,
      ),
    ));

    if (isComplete) {
      LockStakingModel stakingModel = state.lockStakingDetails!;
      stakingModel.rewardRoutes = [
        ...stakingModel.rewardRoutes!,
        state.lockRewardNewRoute!
      ];
      emit(state.copyWith(
        lockStakingDetails: stakingModel,
      ));
    }
  }

  updateRewardPercentages(List<double> values, {int index = 0}) {
    double sum = 0;
    LockStakingModel stakingModel = LockStakingModel.fromJson(
      state.lockStakingDetails!.toJson(),
      reinvest: false,
    );

    for (int i = 0; i < values.length; i++) {
      stakingModel.rewardRoutes![i].rewardPercent = values[i];
      if (stakingModel.rewardRoutes![i].label != 'Reinvest') {
        sum += values[i];
      }
    }
    double reinvestPercent = 1 - sum;

    var reinvest = stakingModel.rewardRoutes!
        .firstWhere((element) => element.label == 'Reinvest');

    reinvest.rewardPercent = reinvestPercent;

    emit(state.copyWith(
      lockStakingDetails: stakingModel,
      lastEditedRewardIndex: index,
    ));
  }

  updateRewardRoutes(
    AccountModel account,
    List<LockRewardRoutesModel> rewardRoutes,
  ) async {
    String errorMessage = '';

    emit(state.copyWith(
      status: LockStatusList.loading,
    ));

    List<LockRewardRoutesModel> routes = List.from(rewardRoutes);
    var temp = routes.firstWhere((element) => element.label == 'Reinvest');
    int index = routes.indexOf(temp);
    routes.removeAt(index);
    var rewardRoutesString = routes.map((e) => e.toJson()).toList();

    try {
      await lockRequests.updateRewards(
        account.lockAccessToken!,
        rewardRoutesString,
        state.lockStakingDetails!.id!,
      );
    } catch (err) {
      String errorString = err.toString();

      if (errorString.contains('Provided duplicated route')) {
        errorMessage = 'Cannot create duplicated route';
      } else {
        errorMessage = jsonDecode(errorString)['message'];
      }
    }

    emit(state.copyWith(
      status: LockStatusList.success,
      lastEditedRewardIndex: 0,
      errorMessage: errorMessage,
    ));
  }

  updateReinvestRewardRoute() {
    double sumPercent = state.lockStakingDetails!.rewardRoutes!
        .map((route) => route.rewardPercent!)
        .reduce((value, element) => value + element);
    double reinvestPercent = 1 - sumPercent;

    var reinvest = state.lockStakingDetails!.rewardRoutes!
        .firstWhere((element) => element.label == 'Reinvest');

    reinvest.rewardPercent = reinvestPercent;
  }

  removeRewardRoute(int index) {
    LockStakingModel stakingModel = LockStakingModel.fromJson(
      state.lockStakingDetails!.toJson(),
      reinvest: false,
    );
    List<LockRewardRoutesModel> routes = stakingModel.rewardRoutes!;
    routes.removeAt(index);

    List<double> rewardPercentages =
      routes.map((e) => e.rewardPercent!).toList();

    emit(state.copyWith(
      lockStakingDetails: stakingModel,
    ));
    updateRewardPercentages(rewardPercentages);
  }

  bool checkVerifiedUser({bool isCheckOnlyKycStatus = false}) {
    if (isCheckOnlyKycStatus) {
      return state.lockUserDetails!.kycStatus! == 'Full' ||
          state.lockUserDetails!.kycStatus! == 'Light';
    } else {
      return state.lockStakingDetails != null &&
          (state.lockUserDetails!.kycStatus! == 'Full' ||
              state.lockUserDetails!.kycStatus! == 'Light');
    }
  }

  bool checkValidKycLink() {
    return state.lockUserDetails!.kycLink == 'https://kyc.lock.space?code=null';
  }

  Future<String?> signIn(AccountModel account, ECPair keyPair) async {
    try {
      late String accessToken;
      accessToken = await lockRequests.signIn(account, keyPair);
      return accessToken == '' ? null : accessToken;
    } catch (err) {
      return null;
    }
  }

  Future<String> createLockAccount(
    AccountModel account,
    ECPair keyPair,
  ) async {
    try {
      late String accessToken;
      accessToken = await lockRequests.signUp(account, keyPair);
      return accessToken;
    } catch (err) {
      throw err;
    }
  }

  Future<String> getAccessToken(
    AccountModel account,
    ECPair keyPair, {
    bool needRefresh = false,
  }) async {
    try {
      late String accessToken;
      accessToken = await lockRequests.signIn(account, keyPair);
      return accessToken;
    } catch (err) {
      throw err;
    }
  }

  loadUserDetails(AccountModel account) async {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));

    try {
      LockUserModel? data =
          await lockRequests.getUser(account.lockAccessToken!);
      emit(state.copyWith(
        status: LockStatusList.success,
        lockUserDetails: data,
      ));
    } catch (err) {
      if (err == '401') {
        emit(state.copyWith(
          status: LockStatusList.expired,
        ));
      } else {
        emit(state.copyWith(
          status: LockStatusList.failure,
        ));
      }
    }
  }

  loadKycDetails(AccountModel account) async {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));

    try {
      LockUserModel? data = await lockRequests.getKYC(account.lockAccessToken!);
      emit(state.copyWith(
        status: LockStatusList.success,
        lockUserDetails: data,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LockStatusList.failure,
      ));
    }
  }

  loadStakingDetails(
    AccountModel account, {
    bool needUserDetails = false,
    bool needKycDetails = false,
  }) async {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));

    try {
      LockUserModel? userData;
      LockAnalyticsModel? analyticsData;
      List<LockAssetModel>? lockAssets;
      LockStakingModel? stakingData = await lockRequests.getStaking(
        account.lockAccessToken!,
        state.lockStrategy.toString(),
      );

      if (state.lockAssets.isEmpty) {
        lockAssets = await lockRequests.getAssets(account.lockAccessToken!);
        updateLockAssetCategory(
          LockAssetCryptoCategory.Crypto,
          list: lockAssets,
        );
      }

      if (needUserDetails) {
        userData = await lockRequests.getUser(account.lockAccessToken!);
      }
      if (needKycDetails) {
        analyticsData = await lockRequests.getAnalytics(
          account.lockAccessToken!,
          state.lockStrategy.toString(),
        );
      }
      emit(state.copyWith(
        status: LockStatusList.success,
        lockStakingDetails: stakingData,
        lockUserDetails: userData,
        lockAnalyticsDetails: analyticsData,
        lockAssets: lockAssets,
        lockRewardNewRoute: LockRewardRoutesModel(
          targetAsset: 'DFI',
          targetBlockchain: 'DeFiChain',
          label: '',
          rewardPercent: 0,
          id: 0,
          targetAddress: '',
        ),
      ));
    } catch (err) {
      if (err == '401') {
        emit(state.copyWith(
          status: LockStatusList.expired,
        ));
      } else {
        emit(state.copyWith(
          status: LockStatusList.failure,
        ));
      }
    }
  }

  loadAnalyticsDetails(AccountModel account) async {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));

    try {
      LockAnalyticsModel? data = await lockRequests.getAnalytics(
        account.lockAccessToken!,
        state.lockStrategy.toString(),
      );
      emit(state.copyWith(
        status: LockStatusList.success,
        lockAnalyticsDetails: data,
      ));
    } catch (err) {
      if (err == '401') {
        emit(state.copyWith(
          status: LockStatusList.expired,
        ));
      } else {
        emit(state.copyWith(
          status: LockStatusList.failure,
        ));
      }
    }
  }

  stake(
    String accessToken,
    int stakingId,
    double amount,
    String txId, {
    String asset = 'DFI',
  }) {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));
    try {
      lockRequests.setDeposit(
        accessToken,
        stakingId,
        amount,
        txId,
        asset: asset,
      );
      emit(state.copyWith(
        status: LockStatusList.success,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LockStatusList.failure,
      ));
    }
  }
}
