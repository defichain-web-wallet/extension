import 'abstract_tx_model.dart';
import 'network_feature.dart';

abstract class AbstractNetwork {
  String get type;
  String get name;
  String get displayName;
  bool get isTestnet;

  List<AbstractTransaction> getHistory(String account);
  BigInt getBalance(String account);
  BigInt getPrice(String currency);
  bool supportsFeatures(List<NetworkFeature> features);
  Uri getTransactionExplorerUrl(String txHash);
  Uri getAccountExplorerUrl(String account);
}
