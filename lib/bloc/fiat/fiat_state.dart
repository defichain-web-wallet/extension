part of 'fiat_cubit.dart';

enum FiatStatusList { initial, loading, success, expired, failure }

class FiatState extends Equatable {
  final FiatStatusList status;
  final String? errorMessage;
  final String? phone;
  final String? countryCode;
  final String? phoneWithoutPrefix;
  final String? numberPrefix;
  final String? email;
  final String? currentIban;
  final String? kycHash;
  final String? kycStatus;
  final String? accessToken;
  final List<String>? ibansList;
  final List<AssetByFiatModel>? assets;
  final List<AssetByFiatModel>? foundAssets;
  final List<FiatHistoryModel> history;
  final IbanModel? activeIban;
  final List<IbanModel>? ibanList;
  final KycModel? personalInfo;
  final List<dynamic>? countryList;
  final List<FiatModel>? buyableFiatList;
  final List<FiatModel>? sellableFiatList;
  final bool? isShowTutorial;
  final bool? isKycDataComplete;
  final LimitModel? limit;
  final CryptoRouteModel? cryptoRoute;

  FiatState({
    this.status = FiatStatusList.initial,
    this.errorMessage,
    this.phone,
    this.countryCode,
    this.phoneWithoutPrefix,
    this.numberPrefix,
    this.email,
    this.currentIban,
    this.kycHash,
    this.kycStatus,
    this.accessToken,
    this.ibansList,
    this.assets,
    this.foundAssets,
    this.history = const [],
    this.activeIban,
    this.ibanList,
    this.personalInfo,
    this.countryList,
    this.buyableFiatList,
    this.sellableFiatList,
    this.isShowTutorial = true,
    this.isKycDataComplete,
    this.limit,
    this.cryptoRoute,
  });

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    phone,
    countryCode,
    phoneWithoutPrefix,
    numberPrefix,
    email,
    currentIban,
    kycHash,
    kycStatus,
    accessToken,
    ibansList,
    assets,
    foundAssets,
    history,
    activeIban,
    ibanList,
    personalInfo,
    countryList,
    buyableFiatList,
    sellableFiatList,
    isShowTutorial,
    isKycDataComplete,
    limit,
    cryptoRoute,
  ];

  FiatState copyWith({
    FiatStatusList? status,
    String? errorMessage,
    String? phone,
    String? countryCode,
    String? phoneWithoutPrefix,
    String? numberPrefix,
    String? email,
    String? currentIban,
    String? kycHash,
    String? kycStatus,
    String? accessToken,
    List<String>? ibansList,
    List<AssetByFiatModel>? assets,
    List<AssetByFiatModel>? foundAssets,
    List<FiatHistoryModel>? history,
    IbanModel? activeIban,
    List<IbanModel>? ibanList,
    KycModel? personalInfo,
    List<dynamic>? countryList,
    List<FiatModel>? buyableFiatList,
    List<FiatModel>? sellableFiatList,
    bool? isShowTutorial,
    bool? isKycDataComplete,
    LimitModel? limit,
    CryptoRouteModel? cryptoRoute,
  }) {
    return FiatState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      phoneWithoutPrefix: phoneWithoutPrefix ?? this.phoneWithoutPrefix,
      numberPrefix: numberPrefix ?? this.numberPrefix,
      email: email ?? this.email,
      currentIban: currentIban ?? this.currentIban,
      kycHash: kycHash ?? this.kycHash,
      kycStatus: kycStatus ?? this.kycStatus,
      accessToken: accessToken ?? this.accessToken,
      ibansList: ibansList ?? this.ibansList,
      assets: assets ?? this.assets,
      foundAssets: foundAssets ?? this.foundAssets,
      history: history ?? this.history,
      activeIban: activeIban,
      ibanList: ibanList ?? this.ibanList,
      personalInfo: personalInfo ?? this.personalInfo,
      countryList: countryList ?? this.countryList,
      buyableFiatList: buyableFiatList ?? this.buyableFiatList,
      sellableFiatList: sellableFiatList ?? this.sellableFiatList,
      isShowTutorial: isShowTutorial ?? this.isShowTutorial,
      isKycDataComplete: isKycDataComplete ?? this.isKycDataComplete,
      limit: limit ?? this.limit,
      cryptoRoute: cryptoRoute ?? this.cryptoRoute,
    );
  }
}