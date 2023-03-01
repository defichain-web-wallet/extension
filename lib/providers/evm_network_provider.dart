import 'package:defi_wallet/models/abstract_tx_model.dart';
import 'package:defi_wallet/models/network_feature.dart';
import 'package:defi_wallet/models/network_type_model.dart';
import 'package:defi_wallet/providers/abstract_explorer_provider.dart';
import 'package:defi_wallet/providers/abstract_network_provider.dart';

import '../models/evm_transaction_receipt.dart';


class EvmNetwork implements AbstractNetwork {
  NetworkDialect dialect = NetworkDialect.EVM;
  String name;
  String displayName;
  bool isTestnet;
  List<String> rpcUrls;
  AbstractExplorer explorer;

  static const List<NetworkFeature> supportedFeatures = [
    NetworkFeature.SWAP,
    NetworkFeature.TOKENS,
    NetworkFeature.SMART_CONTRACTS
  ];

  EvmNetwork({
    required this.name,
    required this.displayName,
    required this.isTestnet,
    required this.rpcUrls,
    required this.explorer
  });

  List<AbstractTransaction> getHistory(String account) {
    return [];
  }

  BigInt getBalance(String account) {
    return BigInt.parse('0');
  }

  BigInt getPrice(String currency) {
    return BigInt.parse('0');
  }

  bool supportsFeatures(List<NetworkFeature> features) {
    for (NetworkFeature feature in features) {
      if (!EvmNetwork.supportedFeatures.contains(feature)) return false;
    }
    return true;
  }

  Uri getTransactionExplorerUrl(String txHash) {
    return explorer.getTransaction(txHash);
  }
  Uri getAccountExplorerUrl(String account) {
    return explorer.getAccount(account);
  }

  EvmTransactionReceipt sendTransaction(dynamic data) {
    return EvmTransactionReceipt(
      hash: '',
      blockHeight: 0
    );
  }

  String signMessage(dynamic data) {
    return '';
  }

  bool validateAddress(String address) {
    return false;
  }
}