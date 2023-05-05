import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_ramp_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/ramp/ramp_user_model.dart';
import 'package:equatable/equatable.dart';

part 'ramp_state.dart';

class RampCubit extends Cubit<RampState> {
  RampCubit() : super(RampState());

  NetworkTypeModel networkTypeModel = NetworkTypeModel(
    networkName: NetworkName.defichainMainnet,
    networkString: 'defichainMainnet',
    isTestnet: false,
  );

  void signIn(AccountModel account, String password) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel ??
        DefichainRampModel(DefichainNetworkModel(networkTypeModel));

    bool isComplete = await defichainRampModel.signIn(account, password);

    print(state.defichainRampModel);

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

  void signUp(AccountModel account, String password) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel ??
        DefichainRampModel(DefichainNetworkModel(networkTypeModel));

    bool isComplete = await defichainRampModel.signUp(account, password);

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

  void createUser(String email, String phone) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.createUser(
        email,
        phone,
        defichainRampModel.accessToken!,
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

  void buy(String iban, AssetByFiatModel asset) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.buy(iban, asset, defichainRampModel.accessToken!);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void sell(String iban, FiatModel fiat) async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.sell(iban, fiat, defichainRampModel.accessToken!);

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

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      CryptoRouteModel? cryptoRouteModel =
          await defichainRampModel.getCryptoRoutes(
        defichainRampModel.accessToken!,
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

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.createCryptoRoute(defichainRampModel.accessToken!);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void loadCountryList() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      List<dynamic> countries = await defichainRampModel.getCountryList(
        defichainRampModel.accessToken!,
      );
      print(countries);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void loadFiatAssets() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      List<FiatModel> fiatAssets = await defichainRampModel.getFiatList(
        defichainRampModel.accessToken!,
      );
      print(fiatAssets);

      emit(state.copyWith(
        status: RampStatusList.success,
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

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      List<FiatHistoryModel> history = await defichainRampModel.getHistory(
        defichainRampModel.accessToken!,
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

  void loadIbans() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      List<IbanModel> ibans = await defichainRampModel.getIbanList(
        defichainRampModel.accessToken!,
      );
      print(ibans);

      emit(state.copyWith(
        status: RampStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: RampStatusList.failure,
      ));
    }
  }

  void loadUserDetails() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      RampUserModel userModel =
          await defichainRampModel.getUserDetails(
        defichainRampModel.accessToken!,
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

  void updateKyc() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.saveKycData(
        KycModel(
          firstname: 'firstname',
          surname: 'surname',
          street: 'street',
          location: 'location',
          accountType: 'accountType',
          zip: 'zip',
          country: Map<dynamic, dynamic>(),
        ),
        defichainRampModel.accessToken!,
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

  void transferKyc() async {
    emit(state.copyWith(
      status: RampStatusList.loading,
    ));

    DefichainRampModel defichainRampModel = state.defichainRampModel!;

    try {
      defichainRampModel.transferKYC(
        defichainRampModel.accessToken!,
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
}
