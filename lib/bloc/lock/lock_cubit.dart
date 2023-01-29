import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/models/account_model.dart';
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
      lockUserDetails: state.lockUserDetails,
      lockStakingDetails: state.lockStakingDetails,
    ));

    try {
      LockUserModel? data =
          await lockRequests.getUser(account.lockAccessToken!);
      print('address: ${data!.kycStatus}');
      emit(state.copyWith(
        status: LockStatusList.success,
        lockUserDetails: data,
        lockStakingDetails: state.lockStakingDetails,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LockStatusList.failure,
        lockUserDetails: state.lockUserDetails,
        lockStakingDetails: state.lockStakingDetails,
      ));
    }
  }

  loadStakingDetails(AccountModel account) async {
    emit(state.copyWith(
      status: LockStatusList.loading,
      lockStakingDetails: state.lockStakingDetails,
      lockUserDetails: state.lockUserDetails,
    ));

    try {
      LockStakingModel? data =
          await lockRequests.getStaking(account.lockAccessToken!);
      emit(state.copyWith(
        status: LockStatusList.success,
        lockStakingDetails: data,
        lockUserDetails: state.lockUserDetails,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LockStatusList.failure,
        lockStakingDetails: state.lockStakingDetails,
        lockUserDetails: state.lockUserDetails,
      ));
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
      lockStakingDetails: state.lockStakingDetails,
      lockUserDetails: state.lockUserDetails,
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
        lockStakingDetails: state.lockStakingDetails,
        lockUserDetails: state.lockUserDetails,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LockStatusList.failure,
        lockStakingDetails: state.lockStakingDetails,
        lockUserDetails: state.lockUserDetails,
      ));
    }
  }
}
