import 'package:bloc/bloc.dart';
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
    ));
    try {
      var stakingRouteBalance =
        await dfxRequests.getStakingRouteBalance(accessToken, address);
      emit(state.copyWith(
        status: StakingStatusList.success,
        amount: stakingRouteBalance['totalAmount'],
      ));
    } catch (err) {
      emit(state.copyWith(
        status: StakingStatusList.failure,
        amount: state.amount,
      ));
    }
  }
}
