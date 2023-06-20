part of 'ramp_cubit.dart';

enum RampStatusList { initial, loading, success, expired, failure }

class RampState extends Equatable {
  final RampStatusList status;
  final AbstractOnOffRamp? dfxRampModel;
  final AccessTokenModel? accessTokenModel;
  final RampUserModel? rampUserModel;
  final RampKycModel? rampKycModel;
  final List<AssetByFiatModel>? assets;
  final List<FiatModel>? fiatAssets;
  final List<IbanModel>? ibans;
  final IbanModel? activeIban;
  final String? newIban;
  final List<dynamic>? countries;

  RampState({
    this.status = RampStatusList.initial,
    this.dfxRampModel,
    this.accessTokenModel,
    this.rampUserModel,
    this.rampKycModel,
    this.assets,
    this.fiatAssets,
    this.ibans,
    this.activeIban,
    this.newIban,
    this.countries,
  });

  bool get hasAccessToken =>
      this.dfxRampModel != null &&
      this.dfxRampModel!.accessTokensMap[0]!.accessToken != null;

  List<IbanModel> uniqueIbans(FiatModel fiat) {
    List<IbanModel> ibans = this
        .ibans!
        .where((element) =>
            element.isSellable! && element.fiat!.name! == fiat.name!)
        .toList();
    List<String> stringIbans = [];
    List<IbanModel> uniqueIbans = [];

    ibans.forEach((element) {
      stringIbans.add(element.iban!);
    });

    var stringUniqueIbans = Set<String>.from(stringIbans).toList();

    stringUniqueIbans.forEach((element) {
      uniqueIbans.add(this.ibans!.firstWhere((el) => el.iban == element));
    });
    return uniqueIbans;
  }

  List<AssetByFiatModel>? get buyableAssets => _getSelectedAssets();

  List<AssetByFiatModel>? get sellableAssets =>
      _getSelectedAssets(isBuyable: false);

  @override
  List<Object?> get props => [
        status,
        dfxRampModel,
        accessTokenModel,
        rampUserModel,
        assets,
        fiatAssets,
        ibans,
        activeIban,
        newIban,
        countries,
        rampKycModel,
      ];

  RampState copyWith({
    RampStatusList? status,
    AbstractOnOffRamp? dfxRampModel,
    AccessTokenModel? accessTokenModel,
    RampUserModel? rampUserModel,
    RampKycModel? rampKycModel,
    List<AssetByFiatModel>? assets,
    List<FiatModel>? fiatAssets,
    List<IbanModel>? ibans,
    IbanModel? activeIban,
    String? newIban,
    List<dynamic>? countries,
  }) {
    return RampState(
      status: status ?? this.status,
      dfxRampModel: dfxRampModel ?? this.dfxRampModel,
      accessTokenModel: accessTokenModel ?? this.accessTokenModel,
      rampUserModel: rampUserModel ?? this.rampUserModel,
      rampKycModel: rampKycModel ?? this.rampKycModel,
      assets: assets ?? this.assets,
      fiatAssets: fiatAssets ?? this.fiatAssets,
      ibans: ibans ?? this.ibans,
      activeIban: activeIban ?? this.activeIban,
      newIban: newIban ?? this.newIban,
      countries: countries ?? this.countries,
    );
  }

  List<AssetByFiatModel>? _getSelectedAssets({bool isBuyable = true}) {
    if (this.assets == null) {
      return null;
    }
    return this.assets!.where((element) {
      if (isBuyable) {
        return element.buyable!;
      } else {
        return element.sellable!;
      }
    }).toList();
  }
}
