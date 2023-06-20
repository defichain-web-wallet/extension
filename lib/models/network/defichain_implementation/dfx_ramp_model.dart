import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_on_off_ramp_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_kyc_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_user_model.dart';
import 'package:defi_wallet/requests/defichain/ramp/dfx_requests.dart';

class DFXRampModel extends AbstractOnOffRamp {
  DFXRampModel() : super();

  factory DFXRampModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return DFXRampModel();
    } else {
      final accessTokensList = json['accessTokensMap'] as Map<String, dynamic>;
      final accessTokensMap = accessTokensList.map(
        (key, value) => MapEntry(
          int.parse(key),
          AccessTokenModel.fromJson(value),
        ),
      );
      return DFXRampModel()..accessTokensMap = accessTokensMap;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.accessTokensMap.isNotEmpty) {
      data["accessTokensMap"] = this.accessTokensMap.map((key, value) {
        return MapEntry(key.toString(), value.toJson());
      });
    }
    return data;
  }

  @override
  Future<void> signIn(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  ) async {
    final data = await _authorizationData(
      account,
      password,
      applicationModel,
      networkModel,
    );
    String? accessToken = await DFXRequests.signIn(data);
    if (accessToken != null) {
      accessTokensMap[account.accountIndex] = AccessTokenModel(
        accessToken: accessToken,
        expireHours: 24,
      );
    }
  }

  Future<bool> signUp(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  ) async {
    var data = await _authorizationData(
      account,
      password,
      applicationModel,
      networkModel,
    );
    String? accessToken = await DFXRequests.signUp(data);
    if (accessToken != null) {
      accessTokensMap[account.accountIndex] = AccessTokenModel(
        accessToken: accessToken,
        expireHours: 24,
      );
      return true;
    }
    return false; //TODO: need to return ErrorModel with details
  }

  @override
  Future<List<AssetByFiatModel>> getAvailableTokens(
    String accessToken,
  ) async {
    try {
      return await DFXRequests.getAvailableAssets(accessToken);
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
      await DFXRequests.buy(iban, asset, accessToken);
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
      await DFXRequests.sell(iban, fiat, accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<CryptoRouteModel> createCryptoRoute(String accessToken) async {
    try {
      return await DFXRequests.createCryptoRoute(accessToken);
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
      await DFXRequests.createUser(email, phone, accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List> getCountryList(String accessToken) async {
    try {
      return await DFXRequests.getCountryList(accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<CryptoRouteModel?> getCryptoRoutes(String accessToken) async {
    try {
      return await DFXRequests.getCryptoRoutes(accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<FiatModel>> getFiatList(String accessToken) async {
    try {
      return await DFXRequests.getFiatList(accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<FiatHistoryModel>> getHistory(String accessToken) async {
    try {
      return await DFXRequests.getHistory(accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<IbanModel>> getIbanList(String accessToken) async {
    try {
      return await DFXRequests.getIbanList(accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<RampUserModel> getUserDetails(String accessToken) async {
    try {
      return DFXRequests.getUserDetails(accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<void> saveKycData(RampKycModel kyc, String accessToken) async {
    try {
      return await DFXRequests.saveKycData(kyc, accessToken);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> transferKYC(String accessToken) async {
    try {
      return await DFXRequests.transferKYC(accessToken);
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

  Future<Map<String, String>> _authorizationData(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  ) async {
    var address = account.getAddress(
      networkModel.networkType.networkName,
    )!;
    String signature = await networkModel.signMessage(
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
