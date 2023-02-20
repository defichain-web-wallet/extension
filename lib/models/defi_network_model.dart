import 'package:defi_wallet/models/abstract_network_model.dart';
import 'package:defi_wallet/models/abstract_tx_model.dart';
import 'package:defi_wallet/models/defi_transaction_receipt.dart';
import 'package:defi_wallet/models/network_feature.dart';
import 'package:defi_wallet/models/network_type_model.dart';

class DefiNetworkModel extends AbstractNetwork {
  String displayName;
  bool isTestnet;
  String name;
  NetworkDialect dialect = NetworkDialect.DFI;

  DefiNetworkModel({
    required this.displayName,
    required this.name,
    required this.isTestnet
  });

  @override
  bool supportsFeatures(List<NetworkFeature> features) {
    // TODO: implement supportsFeatures
    throw UnimplementedError();
  }


  @override
  Uri getAccountExplorerUrl(String account) {
    // TODO: implement getAccountExplorerUrl
    throw UnimplementedError();
  }

  @override
  BigInt getBalance(String account) {
    // TODO: implement getBalance
    throw UnimplementedError();
  }

  @override
  List<AbstractTransaction> getHistory(String account) {
    // TODO: implement getHistory
    throw UnimplementedError();
  }

  @override
  BigInt getPrice(String currency) {
    // TODO: implement getPrice
    throw UnimplementedError();
  }

  @override
  Uri getTransactionExplorerUrl(String txHash) {
    // TODO: implement getTransactionExplorerUrl
    throw UnimplementedError();
  }

  DefiTransactionReceipt sendTransaction(dynamic data) {
    return DefiTransactionReceipt(hash: '', blockHeight: 0);
  }

  String signMessage(dynamic data) {
    return '';
  }

  bool validateAddress(String address) {
    return false;
  }
}