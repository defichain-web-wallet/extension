import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(NetworkState());

  updateCurrentNetwork(NetworkList value) {
    emit(state.copyWith(
      currentNetwork: value,
    ));
  }

  updateCurrentTab(NetworkTabs value) {
    emit(state.copyWith(
      currentNetworkSelectorTab: value,
    ));
  }

  updateTestnetNetworksList(bool status) {
    emit(state.copyWith(
      isShownTestnet: status
    ));
  }
}
