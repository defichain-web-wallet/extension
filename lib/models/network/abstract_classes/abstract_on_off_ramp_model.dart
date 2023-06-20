import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_kyc_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_user_model.dart';

import 'abstract_account_model.dart';

abstract class AbstractOnOffRamp {
  Map<int, AccessTokenModel> accessTokensMap = {};

  AbstractOnOffRamp();

  Future<bool> signUp(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  );

  Future<void> signIn(
    AbstractAccountModel account,
    String password,
    ApplicationModel applicationModel,
    AbstractNetworkModel networkModel,
  );

  Future<void> createUser(
    String email,
    String phone,
    String accessToken,
  );

  Future<CryptoRouteModel?> getCryptoRoutes(String accessToken);

  Future<CryptoRouteModel> createCryptoRoute(String accessToken);

  Future<bool> transferKYC(String accessToken);

  Future<RampUserModel> getUserDetails(String accessToken);

  Future<List<FiatHistoryModel>> getHistory(String accessToken);

  Future<List<IbanModel>> getIbanList(String accessToken);

  Future<List<dynamic>> getCountryList(String accessToken);

  Future<void> saveKycData(RampKycModel kyc, String accessToken);

  Future<List<FiatModel>> getFiatList(String accessToken);

  List<String> getRequiredPaymentInfo();

  void savePaymentData(
    AbstractAccountModel account,
    Map<String, String> paymentData,
  );

  List<Map<String, String>> getSavedPaymentData(AbstractAccountModel account);

  void deleteSavedPaymentData(
    AbstractAccountModel account,
    Map<String, String> paymentData,
  );

  Future<List<AssetByFiatModel>> getAvailableTokens(String accessToken);

  Future<void> buy(
    String iban,
    AssetByFiatModel asset,
    String accessToken,
  );

  void sell(
    String iban,
    FiatModel fiat,
    String accessToken,
  );

  Map<String, dynamic> toJson();
}
