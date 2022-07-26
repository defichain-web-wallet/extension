import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'fiat_state.dart';

class FiatCubit extends Cubit<FiatState> {
  FiatCubit() : super(FiatState());
  DfxRequests dfxRequests = DfxRequests();
  LockHelper lockHelper = LockHelper();

  addContacts(
    String email,
    String phone,
  ) {
    emit(state.copyWith(
      status: FiatStatusList.success,
      phone: phone,
      email: email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      isShowTutorial: state.isShowTutorial,
      personalInfo: state.personalInfo,
    ));
  }

  createUser(String email, String phone, String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
      personalInfo: state.personalInfo,
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
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
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
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: iban,
      ibansList: ibanList,
      assets: state.assets,
      isShowTutorial: state.isShowTutorial,
    ));
  }

  changeCurrentIban(IbanModel iban) => emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: iban.iban,
        ibansList: state.ibansList,
        assets: state.assets,
        activeIban: iban,
        isShowTutorial: state.isShowTutorial,
      ));

  loadUserDetails(String accessToken) async {
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
      phone: state.phone,
      countryCode: state.countryCode,
      phoneWithoutPrefix: state.phoneWithoutPrefix,
      numberPrefix: state.numberPrefix,
      email: state.email,
      currentIban: state.currentIban,
      ibansList: state.ibansList,
      assets: state.assets,
      isShowTutorial: isShowTutorial,
    ));

    try {
      Map<String, dynamic> data = await dfxRequests.getUserDetails(accessToken);


      print(data['depositLimit']);
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: data['phone'],
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: data['mail'],
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        isShowTutorial: isShowTutorial,
        limit: data['depositLimit'],
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: state.assets,
        isShowTutorial: isShowTutorial,
      ));
    }
  }

  loadAvailableAssets(String accessToken) async {
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
      countryList: state.countryList,
      fiatList: state.fiatList,
      isShowTutorial: state.isShowTutorial,
    ));
    try {
      List<AssetByFiatModel> assets =
      await dfxRequests.getAvailableAssets(accessToken);
      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        assets: assets,
        foundAssets: assets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
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
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
      ));
    }
  }

  saveBuyDetails(
      String iban, AssetByFiatModel asset, String accessToken) async {
    await dfxRequests.saveBuyDetails(iban, asset, accessToken);
  }

  loadIbanList(String accessToken, AssetByFiatModel asset) async {
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
      activeIban: state.activeIban,
      ibanList: state.ibanList,
      isShowTutorial: state.isShowTutorial,
    ));
    List<IbanModel> ibanList = await dfxRequests.getIbanList(accessToken);
    List<IbanModel> activeIbanList =
        ibanList.where((el) => el.active!).toList();
    IbanModel? iban;

    try {
      iban = activeIbanList
          .firstWhere((element) => (element.asset!.name == asset.name));
    } catch (_) {
      iban = null;
    }

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
      activeIban: iban,
      ibanList: activeIbanList,
      isShowTutorial: state.isShowTutorial,
    ));
  }

  search(assets, value) {
    List<AssetByFiatModel> search = [];
    if (value == '') {
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
        foundAssets: assets,
        isShowTutorial: state.isShowTutorial,
      ));
    } else {
      assets.forEach((element) {
        if (element.name.contains(value.toUpperCase())) {
          search.add(element);
        } else if (element.name
            .contains(value.replaceAll('d', '').toUpperCase())) {
          search.add(element);
        }
      });
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
        foundAssets: search,
        isShowTutorial: state.isShowTutorial,
      ));
    }
  }

  loadCountryList(String accessToken) async {
    emit(state.copyWith(
      status: FiatStatusList.loading,
    ));

    try {
      List<dynamic> countryList = await dfxRequests.getCountryList(accessToken);
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
        personalInfo: state.personalInfo,
        countryList: countryList,
        isShowTutorial: state.isShowTutorial,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
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
        countryList: state.countryList,
        isShowTutorial: state.isShowTutorial,
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
    ));
    KycModel kyc = KycModel(
      firstname: state.personalInfo!.firstname,
      surname: state.personalInfo!.surname,
      country: state.personalInfo!.country,
      street: street,
      location: city,
      zip: zipCode,
    );
    await dfxRequests.saveKycData(kyc, accessToken);
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
    ));
  }

  loadFiatList(String accessToken) async {
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
    ));
    List<FiatModel> fiatList = await dfxRequests.getFiatList(accessToken);
    List<FiatModel> activeFiatList =
        fiatList.where((el) => el.enable!).toList();
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
      personalInfo: state.personalInfo,
      fiatList: activeFiatList,
      isShowTutorial: state.isShowTutorial,
    ));
  }

  loadAllAssets(String accessToken) async {
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
    ));
    try {
      List<FiatModel> fiatList = await dfxRequests.getFiatList(accessToken);
      List<FiatModel> activeFiatList =
      fiatList.where((el) => el.enable!).toList();

      List<AssetByFiatModel> assets =
      await dfxRequests.getAvailableAssets(accessToken);

      List<IbanModel> ibanList = await dfxRequests.getIbanList(accessToken);
      List<IbanModel> activeIbanList =
      ibanList.where((el) => el.active!).toList();

      emit(state.copyWith(
        status: FiatStatusList.success,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        ibanList: activeIbanList,
        activeIban: state.activeIban,
        assets: assets,
        foundAssets: assets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: activeFiatList,
        isShowTutorial: state.isShowTutorial,
      ));
    } catch (err) {
      lockHelper.lockWallet();
      emit(state.copyWith(
        status: FiatStatusList.failure,
        phone: state.phone,
        countryCode: state.countryCode,
        phoneWithoutPrefix: state.phoneWithoutPrefix,
        numberPrefix: state.numberPrefix,
        email: state.email,
        currentIban: state.currentIban,
        ibansList: state.ibansList,
        ibanList: state.ibanList,
        assets: state.assets,
        activeIban: state.activeIban,
        foundAssets: state.foundAssets,
        personalInfo: state.personalInfo,
        countryList: state.countryList,
        fiatList: state.fiatList,
        isShowTutorial: state.isShowTutorial,
      ));
    }
  }
}
