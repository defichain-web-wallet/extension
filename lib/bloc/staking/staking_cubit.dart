import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/staking_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:equatable/equatable.dart';

part 'staking_state.dart';

class StakingCubit extends Cubit<StakingState> {
  StakingCubit() : super(StakingState());

  DfxRequests dfxRequests = DfxRequests();

  loadStakingRouteBalance(String accessToken, String address) async {
    emit(state.copyWith(
      status: StakingStatusList.loading,
      amount: state.amount,
      rewardType: state.rewardType,
      paymentType: state.paymentType,
      rewardAsset: state.rewardAsset,
      paymentAsset: state.paymentAsset,
      rewardSell: state.rewardSell,
      paybackSell: state.paybackSell,
      routes: state.routes,
    ));
    try {
      var stakingRouteBalance = await dfxRequests.getStakingRouteBalance(accessToken, address);
      List<StakingModel> stakingRoutes = await dfxRequests.getStakingRoutes(accessToken);
      emit(state.copyWith(
        status: StakingStatusList.success,
        amount: stakingRouteBalance['totalAmount'],
        rewardType: state.rewardType,
        paymentType: state.paymentType,
        rewardAsset: state.rewardAsset,
        paymentAsset: state.paymentAsset,
        rewardSell: state.rewardSell,
        paybackSell: state.paybackSell,
        routes: stakingRoutes,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: StakingStatusList.failure,
        amount: state.amount,
        rewardType: state.rewardType,
        paymentType: state.paymentType,
        rewardAsset: state.rewardAsset,
        paymentAsset: state.paymentAsset,
        rewardSell: state.rewardSell,
        paybackSell: state.paybackSell,
        routes: state.routes,
      ));
    }
  }

  setPaymentType(StakingType type) {
    emit(state.copyWith(
      status: StakingStatusList.success,
      amount: state.amount,
      paymentType: type,
      paymentAsset: state.paymentAsset,
      paybackSell: state.paybackSell,
      rewardType: state.rewardType,
      rewardAsset: state.rewardAsset,
      rewardSell: state.rewardSell,
      routes: state.routes,
    ));
  }

  setRewardType(StakingType type) {
    emit(state.copyWith(
      status: StakingStatusList.success,
      amount: state.amount,
      paymentType: state.paymentType,
      paymentAsset: state.paymentAsset,
      paybackSell: state.paybackSell,
      rewardType: type,
      rewardAsset: state.rewardAsset,
      rewardSell: state.rewardSell,
      routes: state.routes,
    ));
  }

  updateRewardInfo(StakingType type, AssetByFiatModel asset, IbanModel iban) {
    emit(state.copyWith(
      status: StakingStatusList.success,
      amount: state.amount,
      paymentType: state.paymentType,
      paymentAsset: state.paymentAsset,
      paybackSell: state.paybackSell,
      rewardType: type,
      rewardAsset: asset,
      rewardSell: iban,
      routes: state.routes,
    ));
  }

  updatePaymentInfo(StakingType type, AssetByFiatModel asset, IbanModel iban) {
    emit(state.copyWith(
      status: StakingStatusList.success,
      amount: state.amount,
      rewardType: state.rewardType,
      rewardAsset: state.rewardAsset,
      rewardSell: state.rewardSell,
      paymentType: type,
      paymentAsset: asset,
      paybackSell: iban,
      routes: state.routes,
    ));
  }

  createStaking(String accessToken, {bool isActive = false, int id = 0}) async {
    AssetByFiatModel? rewardAsset = state.rewardType == StakingType.Wallet ? state.rewardAsset : null;
    AssetByFiatModel? paymentAsset = state.paymentType == StakingType.Wallet ? state.paymentAsset : null;
    IbanModel? rewardSell = state.rewardType == StakingType.BankAccount ? state.rewardSell : null;
    IbanModel? paybackSell = state.paymentType == StakingType.BankAccount ? state.paybackSell : null;

    String address;
    try {
      dynamic response = await dfxRequests.postStaking(
        state.rewardType.toString().split('.')[1],
        state.paymentType.toString().split('.')[1],
        rewardAsset,
        paymentAsset,
        rewardSell,
        paybackSell,
        accessToken,
        isActive: isActive,
        stakingId: id,
      );
      address = response['deposit']['address'];

      emit(state.copyWith(
        status: StakingStatusList.success,
        amount: state.amount,
        paymentType: state.paymentType,
        paymentAsset: state.paymentAsset,
        paybackSell: state.paybackSell,
        rewardType: state.rewardType,
        rewardAsset: state.rewardAsset,
        rewardSell: state.rewardSell,
        depositAddress: address,
        routes: state.routes,
      ));
    } catch (err) {
      throw err;
    }
  }
}
