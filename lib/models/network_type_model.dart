import 'bip32_type_model.dart';

enum NetworkDialect {
  BTC,
  EVM,
  DFI
}

abstract class AbstractNetworkType {
  String messagePrefix;
  NetworkDialect dialect;

  AbstractNetworkType({
    required this.messagePrefix,
    required this.dialect
  });
}

class BtcNetworkType extends AbstractNetworkType {
  String messagePrefix;
  String? bech32;
  Bip32Type bip32;
  int pubKeyHash;
  int scriptHash;
  int wif;

  BtcNetworkType({
    required this.messagePrefix,
    this.bech32,
    required this.bip32,
    required this.pubKeyHash,
    required this.scriptHash,
    required this.wif
  }) : super(messagePrefix: messagePrefix, dialect: NetworkDialect.BTC);

  @override
  String toString() {
    return 'NetworkType{messagePrefix: $messagePrefix, bech32: $bech32, bip32: ${bip32.toString()}, pubKeyHash: $pubKeyHash, scriptHash: $scriptHash, wif: $wif}';
  }
}

class EvmNetworkType extends AbstractNetworkType {
  String messagePrefix;

  EvmNetworkType({
    required this.messagePrefix
  }) : super(messagePrefix: messagePrefix, dialect: NetworkDialect.EVM);
}
