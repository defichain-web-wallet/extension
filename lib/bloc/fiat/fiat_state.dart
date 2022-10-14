part of 'fiat_cubit.dart';

enum FiatStatusList { initial, loading, success, restore, failure }

class FiatState extends Equatable {
  final FiatStatusList status;
  final String? phone;
  final String? countryCode;
  final String? phoneWithoutPrefix;
  final String? numberPrefix;
  final String? email;
  final String? currentIban;
  final String? kycHash;
  final String? accessToken;
  final List<String>? ibansList;
  final List<AssetByFiatModel>? assets;
  final List<AssetByFiatModel>? foundAssets;
  final List<FiatHistoryModel> history;
  final IbanModel? activeIban;
  final List<IbanModel>? ibanList;
  final KycModel? personalInfo;
  final List<dynamic>? countryList;
  final List<FiatModel>? fiatList;
  final bool? isShowTutorial;
  final bool? isKycDataComplete;
  final int? limit;
  final CryptoRouteModel? cryptoRoute;

  FiatState({
    this.status = FiatStatusList.initial,
    this.phone,
    this.countryCode,
    this.phoneWithoutPrefix,
    this.numberPrefix,
    this.email,
    this.currentIban,
    this.kycHash,
    this.accessToken,
    this.ibansList,
    this.assets,
    this.foundAssets,
    this.history = const [],
    this.activeIban,
    this.ibanList,
    this.personalInfo,
    this.countryList,
    this.fiatList,
    this.isShowTutorial = true,
    this.isKycDataComplete,
    this.limit,
    this.cryptoRoute,
  });

  @override
  List<Object?> get props => [
    status,
    phone,
    countryCode,
    phoneWithoutPrefix,
    numberPrefix,
    email,
    currentIban,
    kycHash,
    accessToken,
    ibansList,
    assets,
    foundAssets,
    history,
    activeIban,
    ibanList,
    personalInfo,
    countryList,
    fiatList,
    isShowTutorial,
    isKycDataComplete,
    limit,
    cryptoRoute,
  ];

  FiatState copyWith({
    FiatStatusList? status,
    String? phone,
    String? countryCode,
    String? phoneWithoutPrefix,
    String? numberPrefix,
    String? email,
    String? currentIban,
    String? kycHash,
    String? accessToken,
    List<String>? ibansList,
    List<AssetByFiatModel>? assets,
    List<AssetByFiatModel>? foundAssets,
    List<FiatHistoryModel>? history,
    IbanModel? activeIban,
    List<IbanModel>? ibanList,
    KycModel? personalInfo,
    List<dynamic>? countryList,
    List<FiatModel>? fiatList,
    bool? isShowTutorial,
    bool? isKycDataComplete,
    int? limit,
    CryptoRouteModel? cryptoRoute,
  }) {
    return FiatState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      phoneWithoutPrefix: phoneWithoutPrefix ?? this.phoneWithoutPrefix,
      numberPrefix: numberPrefix ?? this.numberPrefix,
      email: email ?? this.email,
      currentIban: currentIban ?? this.currentIban,
      kycHash: kycHash ?? this.kycHash,
      accessToken: accessToken ?? this.accessToken,
      ibansList: ibansList ?? this.ibansList,
      assets: assets ?? this.assets,
      foundAssets: foundAssets ?? this.foundAssets,
      history: history ?? this.history,
      activeIban: activeIban,
      ibanList: ibanList ?? this.ibanList,
      personalInfo: personalInfo ?? this.personalInfo,
      countryList: countryList ?? this.countryList,
      fiatList: fiatList ?? this.fiatList,
      isShowTutorial: isShowTutorial ?? this.isShowTutorial,
      isKycDataComplete: isKycDataComplete ?? this.isKycDataComplete,
      limit: limit ?? this.limit,
      cryptoRoute: cryptoRoute ?? this.cryptoRoute,
    );
  }
}