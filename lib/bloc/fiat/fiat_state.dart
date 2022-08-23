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
  final List<String>? ibansList;
  final List<AssetByFiatModel>? assets;
  final List<AssetByFiatModel>? foundAssets;
  final IbanModel? activeIban;
  final List<IbanModel>? ibanList;
  final KycModel? personalInfo;
  final List<dynamic>? countryList;
  final List<FiatModel>? fiatList;
  final bool? isShowTutorial;
  final int? limit;

  FiatState({
    this.status = FiatStatusList.initial,
    this.phone,
    this.countryCode,
    this.phoneWithoutPrefix,
    this.numberPrefix,
    this.email,
    this.currentIban,
    this.ibansList,
    this.assets,
    this.foundAssets,
    this.activeIban,
    this.ibanList,
    this.personalInfo,
    this.countryList,
    this.fiatList,
    this.isShowTutorial = true,
    this.limit,
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
    ibansList,
    assets,
    foundAssets,
    activeIban,
    ibanList,
    personalInfo,
    countryList,
    fiatList,
    isShowTutorial,
    limit,
  ];

  FiatState copyWith({
    FiatStatusList? status,
    String? phone,
    String? countryCode,
    String? phoneWithoutPrefix,
    String? numberPrefix,
    String? email,
    String? currentIban,
    List<String>? ibansList,
    List<AssetByFiatModel>? assets,
    List<AssetByFiatModel>? foundAssets,
    IbanModel? activeIban,
    List<IbanModel>? ibanList,
    KycModel? personalInfo,
    List<dynamic>? countryList,
    List<FiatModel>? fiatList,
    bool? isShowTutorial,
    int? limit,
  }) {
    return FiatState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      phoneWithoutPrefix: phoneWithoutPrefix ?? this.phoneWithoutPrefix,
      numberPrefix: numberPrefix ?? this.numberPrefix,
      email: email ?? this.email,
      currentIban: currentIban ?? this.currentIban,
      ibansList: ibansList ?? this.ibansList,
      assets: assets ?? this.assets,
      foundAssets: foundAssets ?? this.foundAssets,
      activeIban: activeIban,
      ibanList: ibanList ?? this.ibanList,
      personalInfo: personalInfo ?? this.personalInfo,
      countryList: countryList ?? this.countryList,
      fiatList: fiatList ?? this.fiatList,
      isShowTutorial: isShowTutorial ?? this.isShowTutorial,
      limit: limit ?? this.limit,
    );
  }
}