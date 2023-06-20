import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_on_off_ramp_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/dfx_ramp_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/ramp/ramp_kyc_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_user_model.dart';
import 'package:equatable/equatable.dart';

part 'ramp_state.dart';

class RampCubit extends Cubit<RampState> {
  RampCubit() : super(RampState());

  Future<void> setAccessToken(AccessTokenModel accessTokenModel) async {
    AbstractOnOffRamp defichainRampModel = state.defichainRampModel ??
        DFXRampModel();

    emit(state.copyWith(
      status: RampStatusList.initial,
      accessTokenModel: accessTokenModel,
      defichainRampModel: defichainRampModel,
    ));
  }

  Future<void> signIn(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
  ) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel ??
        DFXRampModel();

    try {
      await defichainRampModel.signIn(
        account,
        password,
        applicationModel,
        applicationModel.activeNetwork!,
      );

      emit(state.copyWith(
        status: RampStatusList.success,
        defichainRampModel: defichainRampModel,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  Future<void> signUp(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
  ) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel ??
        DFXRampModel();

    bool isComplete = await defichainRampModel.signUp(
      account,
      password,
      applicationModel,
      applicationModel.activeNetwork!,
    );

    if (isComplete) {
      emit(state.copyWith(
        status: RampStatusList.success,
        defichainRampModel: defichainRampModel,
      ));
    } else {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  Future<void> createUser(String email, String phone) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.createUser(
        email,
        phone,
        state.accessTokenModel!.accessToken,
      );

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  Future<void> buy(String iban, AssetByFiatModel asset) async {
    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      await defichainRampModel.buy(iban, asset, state.accessTokenModel!.accessToken);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (_) {
      // TODO: need to handle error inside bloc
      rethrow;
    }
  }

  Future<void> sell(String iban, FiatModel fiat) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.sell(iban, fiat, state.accessTokenModel!.accessToken);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void getCryptoRoutes() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      CryptoRouteModel? cryptoRouteModel =
          await defichainRampModel.getCryptoRoutes(
        state.accessTokenModel!.accessToken,
      );
      print(cryptoRouteModel);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void addCryptoRoute() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.createCryptoRoute(state.accessTokenModel!.accessToken);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void loadCountries() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      List<dynamic> countries = await defichainRampModel.getCountryList(
        state.accessTokenModel!.accessToken,
      );
      print(countries);

      emit(state.copyWith(
        status: RampStatusList.success,
        countries: countries,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  Future<void> loadAssets() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      List<AssetByFiatModel> assets =
          await defichainRampModel.getAvailableTokens(
        state.accessTokenModel!.accessToken,
      );

      emit(state.copyWith(
        status: RampStatusList.success,
        assets: assets,
      ));
    } catch (error) {
      print(error);
    }
  }

  void loadFiatAssets() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      List<FiatModel> fiatAssets = await defichainRampModel.getFiatList(
        state.accessTokenModel!.accessToken,
      );

      List<FiatModel> sellableFiatList =
        fiatAssets.where((el) => el.sellable!).toList();

      List<AssetByFiatModel> assets =
          await defichainRampModel.getAvailableTokens(
        state.accessTokenModel!.accessToken,
      );

      List<IbanModel> ibanList = await defichainRampModel.getIbanList(
        state.accessTokenModel!.accessToken,
      );
      List<IbanModel> activeIbanList =
        ibanList.where((el) => el.active! && el.isSellable!).toList();
      IbanModel? iban;

      try {
        if (state.newIban != null && state.newIban != '') {
          iban = activeIbanList
              .firstWhere((element) => (element.iban == state.newIban!.replaceAll(' ', '')));
        } else {
          iban = activeIbanList.firstWhere((element) => element.isSellable!);
        }
      } catch (_) {
        iban = null;
      }

      emit(state.copyWith(
        status: RampStatusList.success,
        fiatAssets: sellableFiatList,
        assets: assets,
        activeIban: iban,
        ibans: ibanList,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void loadHistory() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      List<FiatHistoryModel> history = await defichainRampModel.getHistory(
        state.accessTokenModel!.accessToken,
      );
      print(history);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void loadIbans({
    AssetByFiatModel? asset,
    bool isNewIban = false,
    bool isSellable = false,
  }) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      List<IbanModel> ibans = await defichainRampModel.getIbanList(
        state.accessTokenModel!.accessToken,
      );
      List<IbanModel> ibansList = ibans
          .where((el) =>
      el.active! &&
          el.isSellable == isSellable &&
          asset!.name == el.asset!.name)
          .toList();
      IbanModel? iban;
      print(ibans);

      try {
        if (asset != null) {
          iban = ibansList.firstWhere((element) =>
          element.asset!.name == asset.name);
        } else if (isNewIban && asset != null) {
          iban = ibansList.firstWhere(
                (element) =>
            element.asset!.name == asset.name &&
                element.iban == state.newIban!.replaceAll(' ', ''),
          );
        } else {
          iban = ibansList[0];
        }
      } catch (_) {
        iban = null;
      }

      emit(state.copyWith(
        status: RampStatusList.success,
        ibans: ibansList,
        activeIban: iban,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }

  }

  changeCurrentIban(IbanModel iban) => emit(state.copyWith(
    status: RampStatusList.success,
    newIban: iban.iban,
    activeIban: iban,
  ));

  void loadUserDetails() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      RampUserModel userModel =
          await defichainRampModel.getUserDetails(
        state.accessTokenModel!.accessToken,
      );

      emit(state.copyWith(
        status: RampStatusList.success,
        rampUserModel: userModel,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void transferKyc() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.transferKYC(
        state.accessTokenModel!.accessToken,
      );

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  setUserName(String firstname, String surname) {
    Map? country;
    String? street;
    String? location;
    String? zip;

    if (state.rampKycModel != null) {
      country = state.rampKycModel!.country ?? null;
    }
    if (state.rampKycModel != null) {
      street = state.rampKycModel!.street ?? null;
    }
    if (state.rampKycModel != null) {
      location = state.rampKycModel!.location ?? null;
    }
    if (state.rampKycModel != null) {
      zip = state.rampKycModel!.zip ?? null;
    }
    RampKycModel rampKycModel = RampKycModel(
      firstname: firstname,
      surname: surname,
      country: country,
      street: street,
      location: location,
      zip: zip,
    );
    emit(state.copyWith(
      status: RampStatusList.success,
      rampKycModel: rampKycModel,
    ));
  }

  setCountry(Map country) {
    RampKycModel rampKycModel = RampKycModel(
      firstname: state.rampKycModel!.firstname,
      surname: state.rampKycModel!.surname,
      country: country,
      street: state.rampKycModel!.street ?? null,
      location: state.rampKycModel!.location ?? null,
      zip: state.rampKycModel!.zip ?? null,
    );
    emit(state.copyWith(
      status: RampStatusList.success,
      rampKycModel: rampKycModel,
    ));
  }

  Future<void> updateKyc(
    String street,
    String city,
    String zipCode,
  ) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    RampKycModel kyc = RampKycModel(
      firstname: state.rampKycModel!.firstname,
      surname: state.rampKycModel!.surname,
      country: state.rampKycModel!.country,
      street: street,
      location: city,
      zip: zipCode,
    );
    AbstractOnOffRamp defichainRampModel = state.defichainRampModel!;

    try {
      await defichainRampModel.saveKycData(
        kyc,
        state.accessTokenModel!.accessToken,
      );
    } catch (err) {
      rethrow;
    } finally {
      emit(state.copyWith(
        status: RampStatusList.success,
        rampKycModel: kyc,
      ));
    }
  }
}
