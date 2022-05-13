import 'package:defi_wallet/models/test_pool_swap_model.dart';

abstract class DexState {}

class DexInitialState extends DexState {}

class DexLoadingState extends DexState {}

class DexLoadedState extends DexState {
  final TestPoolSwapModel dexModel;

  DexLoadedState(this.dexModel);
}
