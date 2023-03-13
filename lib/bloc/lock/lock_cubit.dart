import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/lock_analytics_model.dart';
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
    return state.lockUserDetails!.kycLink ==
        'https://kyc.lock.space?code=null';
  }

  Future<String?> signIn(
      AccountModel account,
      ECPair keyPair) async {
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
      LockUserModel? data =
          await lockRequests.getKYC(account.lockAccessToken!);
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
      LockStakingModel? stakingData =
      await lockRequests.getStaking(account.lockAccessToken!);

      if (needUserDetails) {
        userData =
        await lockRequests.getUser(account.lockAccessToken!);
      }
      if (needKycDetails) {
        analyticsData =
        await lockRequests.getAnalytics(account.lockAccessToken!);
      }
      emit(state.copyWith(
        status: LockStatusList.success,
        lockStakingDetails: stakingData,
        lockUserDetails: userData,
        lockAnalyticsDetails: analyticsData,
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
      LockAnalyticsModel? data =
          await lockRequests.getAnalytics(account.lockAccessToken!);
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
    String txId,
  ) {
    emit(state.copyWith(
      status: LockStatusList.loading,
    ));
    try {
      lockRequests.setDeposit(
        accessToken,
        stakingId,
        amount,
        txId,
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
