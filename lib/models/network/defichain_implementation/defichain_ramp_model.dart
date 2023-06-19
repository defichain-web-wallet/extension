import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_on_off_ramp_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/network_type_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_kyc_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_user_model.dart';
import 'package:defi_wallet/requests/defichain/ramp/dfx_requests.dart';

class DefichainRampModel extends AbstractOnOffRamp {
  DefichainRampModel(AbstractNetworkModel networkModel)
      : super(_validationNetworkModel(networkModel));

  static AbstractNetworkModel _validationNetworkModel(
    AbstractNetworkModel networkModel,
  ) {
    if (networkModel.networkType.networkName.name !=
        NetworkName.defichainMainnet.name) {
      throw 'Invalid network';
    }
    return networkModel;
  }

  @override
  Future<void> signIn(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
  ) async {
    final data = await _authorizationData(account, password, applicationModel);
    String? accessToken = await DFXRequests.signIn(data);
    if (accessToken != null) {
      this.accessToken = accessToken;
      this.accessTokenCreated = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<bool> signUp(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
  ) async {
    var data = await _authorizationData(account, password, applicationModel);
    String? accessToken = await DFXRequests.signUp(data);
    if (accessToken != null) {
      this.accessToken = accessToken;
      this.accessTokenCreated = DateTime.now().millisecondsSinceEpoch;
      return true;
    }
    return false; //TODO: need to return ErrorModel with details
  }

  @override
  Future<List<AssetByFiatModel>> getAvailableTokens() async {
    try {
      return await DFXRequests.getAvailableAssets(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<void> buy(
    String iban,
    AssetByFiatModel asset,
    String accessToken,
  ) async {
    try {
      await DFXRequests.buy(iban, asset, this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  void sell(
    String iban,
    FiatModel fiat,
    String accessToken,
  ) async {
    try {
      await DFXRequests.sell(iban, fiat, this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<CryptoRouteModel> createCryptoRoute(String accessToken) async {
    try {
      return await DFXRequests.createCryptoRoute(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<void> createUser(
    String email,
    String phone,
    String accessToken,
  ) async {
    try {
      await DFXRequests.createUser(email, phone, this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List> getCountryList(String accessToken) async {
    try {
      return await DFXRequests.getCountryList(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<CryptoRouteModel?> getCryptoRoutes(String accessToken) async {
    try {
      return await DFXRequests.getCryptoRoutes(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<FiatModel>> getFiatList(String accessToken) async {
    try {
      return await DFXRequests.getFiatList(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<FiatHistoryModel>> getHistory(String accessToken) async {
    try {
      return await DFXRequests.getHistory(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<IbanModel>> getIbanList() async {
    try {
      return await DFXRequests.getIbanList(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<RampUserModel> getUserDetails(String accessToken) async {
    try {
      return DFXRequests.getUserDetails(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<void> saveKycData(RampKycModel kyc) async {
    try {
      return await DFXRequests.saveKycData(kyc, this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> transferKYC(String accessToken) async {
    try {
      return await DFXRequests.transferKYC(this.accessToken!);
    } catch (error) {
      throw error;
    }
  }

  @override
  void deleteSavedPaymentData(
    AbstractAccountModel account,
    Map<String, String> paymentData,
  ) {
    // TODO: implement deleteSavedPaymentData
  }

  @override
  List<String> getRequiredPaymentInfo() {
    // TODO: implement getRequiredPaymentInfo
    throw UnimplementedError();
  }

  @override
  List<Map<String, String>> getSavedPaymentData(AbstractAccountModel account) {
    // TODO: implement getSavedPaymentData
    throw UnimplementedError();
  }

  @override
  void savePaymentData(
    AbstractAccountModel account,
    Map<String, String> paymentData,
  ) {
    // TODO: implement savePaymentData
  }

  Future<Map<String, String>> _authorizationData(AbstractAccountModel account,
      String password, ApplicationModel applicationModel) async {
    var address = account.getAddress(
      this.networkModel.networkType.networkName,
    )!;
    String signature = await this.networkModel.signMessage(
        account,
        'By_signing_this_message,_you_confirm_that_you_are_the_sole_owner_of_the_provided_DeFiChain_address_and_are_in_possession_of_its_private_key._Your_ID:_$address',
        password,
        applicationModel);
    return {
      'address': address,
      'blockchain': 'DeFiChain',
      'walletName': 'Jelly',
      'signature': signature,
    };
  }
}
