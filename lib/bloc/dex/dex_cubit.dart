import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/dex/dex_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/dex_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/models/token_model.dart';

class DexCubit extends Cubit<DexState> {
  DexCubit() : super(DexInitialState());
  DexHelper _dexHelper = DexHelper();

  Future<void> updateDex(
    String tokenFrom,
    String tokenTo,
    double? amountFrom,
    double? amountTo,
    String address,
    List<AddressModel> addressList,
    TokensState tokensState,
  ) async {
    TestPoolSwapModel dexModel;
    TestPoolSwapModel initModel;
    initModel = await _dexHelper.calculateDex(
      tokenFrom,
      tokenTo,
      1,
      0,
      address,
      addressList,
      tokensState,
    );
    emit(DexLoadingState(initModel: initModel));
    if (tokenFrom == tokenTo) {
      dexModel = TestPoolSwapModel(
        tokenFrom: tokenFrom,
        tokenTo: tokenTo,
        amountFrom: 0,
        amountTo: 0,
        priceFrom: 1,
        priceTo: 1,
      );
      emit(DexLoadedState(dexModel, initModel: initModel));
    } else {
      try {
        dexModel = await _dexHelper.calculateDex(
          tokenFrom,
          tokenTo,
          amountFrom,
          amountTo,
          address,
          addressList,
          tokensState,
        );
        emit(DexLoadedState(dexModel, initModel: initModel));
      } catch (err) {
        emit(DexErrorState());
      }
    }
  }

  Future<void> updateBtcDex(
    String tokenFrom,
    String tokenTo,
    double amountFrom,
    double amountTo,
  ) async {
    TestPoolSwapModel dexModel = TestPoolSwapModel(
      tokenFrom: tokenFrom,
      tokenTo: tokenTo,
      amountFrom: amountFrom,
      amountTo: amountTo,
      priceFrom: 1,
      priceTo: 1,
    );
    emit(DexLoadedState(dexModel));
  }
}
