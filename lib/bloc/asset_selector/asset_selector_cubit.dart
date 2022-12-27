import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/models/token_model.dart';

part 'asset_selector_state.dart';

class AssetSelectorCubit extends Cubit<AssetSelectorState> {
  AssetSelectorCubit() : super(AssetSelectorState());

  void updateCurrentAsset(TokensModel asset) {
    emit(state.copyWith(
      currentAsset: asset,
    ));
  }
}
