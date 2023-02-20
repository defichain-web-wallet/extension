import 'package:defi_wallet/models/network_type_model.dart';

import 'abstract_tx_model.dart';
import 'network_feature.dart';

abstract class AbstractNetwork {
  NetworkDialect get dialect;
  String get name;
  String get displayName;
  bool get isTestnet;

  List<AbstractTransaction> getHistory(String account);
  BigInt getBalance(String account);
  BigInt getPrice(String currency);
  bool supportsFeatures(List<NetworkFeature> features);
  Uri getTransactionExplorerUrl(String txHash);
  Uri getAccountExplorerUrl(String account);
  String signMessage(dynamic data);
  bool validateAddress(String address);
}
