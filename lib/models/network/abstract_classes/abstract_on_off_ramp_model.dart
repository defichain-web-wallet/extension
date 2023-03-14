import 'dart:ffi';

import 'package:defi_wallet/models/token_model.dart';

import 'abstract_account_model.dart';

class Price {
  String currencyId;
  Double? buyPrice;
  Double? sellPrice;

  Price(this.currencyId, this.buyPrice, this.sellPrice);
}

class RampTokenModel extends TokensModel {
  List<Price> prices;
  RampTokenModel(this.prices);
}

abstract class AbstractOnOffRamp {
  List<String> getRequiredPaymentInfo();
  void savePaymentData(
      AbstractAccountModel account, Map<String, String> paymentData);
  List<Map<String, String>> getSavedPaymentData(AbstractAccountModel account);
  void deleteSavedPaymentData(
      AbstractAccountModel account, Map<String, String> paymentData);

  List<RampTokenModel> availableTokens();
  String buy(AbstractAccountModel account, String password, TokensModel token,
      double amount, Map<String, String> paymentData);
  String sell(AbstractAccountModel account, String password, TokensModel token,
      double amount, Map<String, String> paymentData);
}
