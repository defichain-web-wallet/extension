import 'package:defi_wallet/models/test_pool_swap_model.dart';

abstract class DexState {}

class DexInitialState extends DexState {
  final TestPoolSwapModel? initModel;

  DexInitialState({this.initModel});
}

class DexLoadingState extends DexState {
  final TestPoolSwapModel? initModel;

  DexLoadingState({this.initModel});
}

class DexLoadedState extends DexState {
  final TestPoolSwapModel dexModel;
  final TestPoolSwapModel? initModel;

  DexLoadedState(this.dexModel, {this.initModel});
}

class DexErrorState extends DexState {}
