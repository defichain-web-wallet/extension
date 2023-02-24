part of 'asset_selector_cubit.dart';

enum AssetSelectorStatusList { initial, success, failure }

class AssetSelectorState extends Equatable {
  final AssetSelectorStatusList status;
  final List<TokensModel>? assets;
  final TokensModel? currentAsset;

  AssetSelectorState({
    this.status = AssetSelectorStatusList.initial,
    this.assets,
    this.currentAsset,
  });

  @override
  List<Object?> get props => [
    status,
    assets,
    currentAsset,
  ];

  AssetSelectorState copyWith({
    AssetSelectorStatusList? status,
    List<TokensModel>? assets,
    TokensModel? currentAsset,
  }) {
    return AssetSelectorState(
      status: status ?? this.status,
      assets: assets ?? this.assets,
      currentAsset: currentAsset ?? this.currentAsset,
    );
  }
}
