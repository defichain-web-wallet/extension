import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/limit_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'fiat_state.dart';

class FiatCubit extends Cubit<FiatState> {
  FiatCubit() : super(FiatState());
  DfxRequests dfxRequests = DfxRequests();
  LockHelper lockHelper = LockHelper();
  EncryptHelper encryptHelper = EncryptHelper();

  setLoadingState() {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));
  }

  addContacts(
    String email,
    String phone,
  ) {
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: phone,
      email: email,
    ));
  }

  createUser(String email, String phone, String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));
    await dfxRequests.createUser(
      email,
      phone,
      accessToken,
    );
    addContacts(email, phone);
  }

  changeStatusTutorial(bool status) async {
    var box = await Hive.openBox(HiveBoxes.client);
    String tutorialStatus = !status ? 'skip' : 'show';
    await box.put(HiveNames.tutorialStatus, tutorialStatus);
    await box.close();

    emit(state.copyWith(
      status: FiatStatusList.success,
      isShowTutorial: status,
    ));
  }

  addIban(String iban) {
    List<String>? ibanList;
    if (state.ibansList != null) {
      ibanList = state.ibansList!;
      ibanList.add(iban);
    } else {
      ibanList = [iban];
    }

    emit(state.copyWith(
      status: FiatStatusList.success,
      currentIban: iban,
      ibansList: ibanList,
    ));
  }

  changeCurrentIban(IbanModel iban) => emit(state.copyWith(
        status: FiatStatusList.success,
        currentIban: iban.iban,
        activeIban: iban,
      ));

  loadUserDetails(AccountModel account) async {
    var box = await Hive.openBox(HiveBoxes.client);
    String? tutorialStatus = await box.get(HiveNames.tutorialStatus);
    bool isShowTutorial;
    if (tutorialStatus == null) {
      isShowTutorial = state.isShowTutorial!;
    } else {
      isShowTutorial = tutorialStatus == 'show';
    }

    await box.close();
    emit(state.copyWith(
      status: FiatStatusList.loading,
      isShowTutorial: isShowTutorial,
    ));

    try {
      String accessToken = state.accessToken ?? await getAccessTokenFromStorage(account);
      Map<String, dynamic> data = await dfxRequests.getUserDetails(accessToken);
      List<FiatHistoryModel> history = await dfxRequests.getHistory(accessToken);

      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: data['phone'],
        kycHash: data['kycHash'],
        kycStatus: data['kycStatus'],
        email: data['mail'],
        isShowTutorial: isShowTutorial,
        accessToken: accessToken,
        isKycDataComplete: data['kycDataComplete'],
        limit: LimitModel.fromJson(data['tradingLimit']),
        history: history,
      ));
    } catch (err) {
      if (err == '401') {
        emit(state.copyWith(
          status: FiatStatusList.expired,
        ));
      } else {
        emit(state.copyWith(
          status: FiatStatusList.failure,
          isShowTutorial: isShowTutorial,
        ));
      }
    }
  }

  loadAvailableAssets() async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));
    try {
      List<AssetByFiatModel> buyableAssets =
      await dfxRequests.getAvailableAssets(state.accessToken!);

      List<AssetByFiatModel> result =
          buyableAssets.where((element) => element.buyable!).toList();
      emit(state.copyWith(
        status: FiatStatusList.success,
        assets: result,
        foundAssets: result,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
      ));
    }
  }

  saveBuyDetails(
    String iban,
    AssetByFiatModel asset,
    String accessToken,
  ) async {
    await dfxRequests.saveBuyDetails(iban, asset, accessToken);
    emit(state.copyWith(
      status: FiatStatusList.loading,
      currentIban: iban,
    ));
  }

  loadIbanList({AssetByFiatModel? asset, bool isNewIban = false}) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));
    List<IbanModel> ibanList = await dfxRequests.getIbanList(state.accessToken!);
    List<IbanModel> activeIbanList = ibanList
        .where((el) =>
            el.active! &&
            el.type == 'Wallet' &&
            asset!.name == el.asset!.name)
        .toList();
    IbanModel? iban;

    try {
      if (asset != null) {
        iban = activeIbanList.firstWhere((element) =>
          element.asset!.name == asset.name);
      } else if (isNewIban && asset != null) {
        iban = activeIbanList.firstWhere(
          (element) =>
              element.asset!.name == asset.name &&
              element.iban == state.currentIban!.replaceAll(' ', ''),
        );
      } else {
        iban = activeIbanList[0];
      }
    } catch (_) {
      iban = null;
    }

    emit(state.copyWith(
      status: FiatStatusList.success,
      currentIban: '',
      activeIban: iban,
      ibanList: activeIbanList,
    ));
  }

  search(assets, value) {
    List<AssetByFiatModel> search = [];

    if (value != '') {
      assets.forEach((element) {
        if (element.name.contains(value.toUpperCase())) {
          search.add(element);
        } else if (element.name
            .contains(value.replaceAll('d', '').toUpperCase())) {
          search.add(element);
        }
      });
    } else {
      search = assets;
    }

    emit(state.copyWith(
      status: FiatStatusList.success,
      foundAssets: search,
    ));
  }

  loadCountryList() async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));

    try {
      List<dynamic> countryList = await dfxRequests.getCountryList(state.accessToken!);
      emit(state.copyWith(
        status: FiatStatusList.success,
        countryList: countryList,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
      ));
    }
  }

  setUserName(String firstname, String surname) {
    Map? country;
    String? street;
    String? location;
    String? zip;
    if (state.personalInfo != null) {
      country = state.personalInfo!.country ?? null;
    }
    if (state.personalInfo != null) {
      street = state.personalInfo!.street ?? null;
    }
    if (state.personalInfo != null) {
      location = state.personalInfo!.location ?? null;
    }
    if (state.personalInfo != null) {
      zip = state.personalInfo!.zip ?? null;
    }
    KycModel kyc = KycModel(
      firstname: firstname,
      surname: surname,
      country: country,
      street: street,
      location: location,
      zip: zip,
    );
    emit(state.copyWith(
      status: FiatStatusList.success,
      personalInfo: kyc,
    ));
  }

  setCountry(Map country) {
    KycModel kyc = KycModel(
      firstname: state.personalInfo!.firstname,
      surname: state.personalInfo!.surname,
      country: country,
      street: state.personalInfo!.street ?? null,
      location: state.personalInfo!.location ?? null,
      zip: state.personalInfo!.zip ?? null,
    );
    emit(state.copyWith(
      status: FiatStatusList.success,
      personalInfo: kyc,
    ));
  }

  setAddress(
      String street, String city, String zipCode, String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      foundAssets: state.foundAssets,
      personalInfo: state.personalInfo,
      isShowTutorial: state.isShowTutorial,
      kycHash: state.kycHash,
      isKycDataComplete: state.isKycDataComplete,
      limit: state.limit,
      history: state.history,
      accessToken: state.accessToken,
    ));
    KycModel kyc = KycModel(
      firstname: state.personalInfo!.firstname,
      surname: state.personalInfo!.surname,
      country: state.personalInfo!.country,
      street: street,
      location: city,
      zip: zipCode,
    );
    try {
      await dfxRequests.saveKycData(kyc, accessToken);
    } catch (err) {
      throw err;
    } finally {
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        foundAssets: state.foundAssets,
        personalInfo: kyc,
        isShowTutorial: state.isShowTutorial,
        kycHash: state.kycHash,
        isKycDataComplete: state.isKycDataComplete,
        limit: state.limit,
        history: state.history,
        accessToken: state.accessToken,
      ));
    }
  }

  loadAllAssets({bool isSell = false}) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));
    try {
      List<FiatModel> fiatList = await dfxRequests.getFiatList(state.accessToken!);
      List<FiatModel> sellableFiatList =
        fiatList.where((el) => el.sellable!).toList();
      List<FiatModel> buyableFiatList =
        fiatList.where((el) => el.buyable!).toList();

      List<AssetByFiatModel> assets =
      await dfxRequests.getAvailableAssets(state.accessToken!);

      List<IbanModel> ibanList = await dfxRequests.getIbanList(state.accessToken!);
      String targetType = (isSell) ? 'Sell' : 'Wallet';
      List<IbanModel> activeIbanList =
      ibanList.where((el) => el.active! && el.type == targetType).toList();
      IbanModel? iban;

      try {
        if (state.currentIban != null && state.currentIban != '') {
          iban = activeIbanList
              .firstWhere((element) => (element.iban == state.currentIban!.replaceAll(' ', '')));
        } else {
          if (isSell) {
            iban = activeIbanList.firstWhere((element) => element.type == 'Sell');
          } else {
            iban = activeIbanList[0];
          }
        }
      } catch (_) {
        iban = null;
      }

      emit(state.copyWith(
        status: FiatStatusList.success,
        ibanList: activeIbanList,
        activeIban: iban,
        assets: assets,
        foundAssets: assets,
        sellableFiatList: sellableFiatList,
        buyableFiatList: buyableFiatList,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
      ));
    }
  }

  Future<void> loadCryptoRoute(AccountModel account) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));
    try {
      String accessToken = state.accessToken ?? await getAccessTokenFromStorage(account);
      Map<String, dynamic> data = await dfxRequests.getUserDetails(accessToken);

      CryptoRouteModel? route;
      if (data['kycDataComplete']) {
        route = await dfxRequests.getCryptoRoutes(accessToken);
        if (route == null && data['kycStatus'] == 'Completed') {
          route = await dfxRequests.createCryptoRoute(accessToken);
        }
      }
      emit(state.copyWith(
        status: FiatStatusList.success,
        cryptoRoute: route,
        accessToken: accessToken,
        kycHash: data['kycHash'],
        isKycDataComplete: data['kycDataComplete'],
        kycStatus: data['kycStatus'],
      ));
    } catch (err) {
      emit(state.copyWith(
        status: FiatStatusList.failure,
      ));
    }
  }

  Future<String?> signIn(
      AccountModel account,
      ECPair keyPair) async {
    try {
      late String accessToken;
      accessToken = await dfxRequests.signIn(account, keyPair);
      return accessToken == '' ? null : accessToken;
    } catch (err) {
      return null;
    }
  }

  Future<String?> signUp(
    AccountModel account,
    ECPair keyPair,
  ) async {
    try {
      late String accessToken;
      accessToken = await dfxRequests.signUp(account, keyPair);
      return accessToken == '' ? null : accessToken;
    } catch (err) {
      return null;
    }
  }

  Future<String> getAccessToken(
    AccountModel account,
    ECPair keyPair, {
    bool needRefresh = false,
  }) async {
    try {
      late String accessToken;
      if (needRefresh) {
        accessToken = await dfxRequests.signIn(account, keyPair);
      } else {
        accessToken =
            state.accessToken ?? await dfxRequests.signIn(account, keyPair);
      }
      return accessToken;
    } catch (err) {
      throw err;
    }
  }

  Future<String> getAccessTokenFromStorage(AccountModel activeAccount) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    late String accessToken;
    var box = await Hive.openBox(HiveBoxes.client);

    try {
      var accounts = await box.get(HiveNames.accountsMainnet);
      var decodeAccounts = stringToBase64.decode(accounts);
      List<dynamic> accountsList = json.decode(decodeAccounts);
      for (var account in accountsList) {
        AccountModel accountModel = AccountModel.fromJson(account);
        if (accountModel.index == activeAccount.index) {
          if (accountModel.accessToken!.isNotEmpty) {
            accessToken = accountModel.accessToken!;
          } else {
            accessToken = accountsList[0]['accessToken'];
          }
        }
      }
      return accessToken;
    } catch (err) {
      throw err;
    } finally {
      await box.close();
    }
  }

  List<AssetByFiatModel> getAssetsWithoutPair(List<AssetByFiatModel> assets) {
    List<AssetByFiatModel> filteredAssets = [];
    assets.forEach((element) {
      if(!element.isPair!) {
        filteredAssets.add(element);
      }
    });
    return filteredAssets;
  }
}
