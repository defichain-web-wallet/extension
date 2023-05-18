import 'package:crypt/crypt.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';

class ApplicationModel {
  final Map<String, SourceSeedModel> sourceList;
  late String password;
  late List<AbstractNetworkModel> networks;

  ApplicationModel(this.sourceList, password) {
    this.password = encryptPassword(password);

    this.networks = [
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainTestnet,
          networkString: 'testnet',
          isTestnet: true)),
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainMainnet,
          networkString: 'mainnet',
          isTestnet: false)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: 'mainnet',
          isTestnet: false)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: 'testnet',
          isTestnet: false))
    ];
  }

  String encryptPassword(String password){
    return Crypt.sha256(password).toString();
  }

  bool validatePassword(String password){
    return Crypt(this.password).match(password);
  }

  List<AbstractNetworkModel> getNetworks({required bool isTestnet}) {
    return networks
        .where((element) => isTestnet == element.networkType.isTestnet)
        .toList();
  }

  Map<String, dynamic> toJSON() {
    return {
      'sourceList': sourceList.map((key, value) => MapEntry(key, value.toJSON())),
      'password': password
    };
  }

  factory ApplicationModel.fromJSON(Map<String, dynamic> json) {
    final sourceList = json['sourceList'] as Map<String, dynamic>;
    final password = json['password'] as String;

    final sourceListMapped = sourceList.map(
          (key, value) => MapEntry(key, SourceSeedModel.fromJSON(value)),
    );

    return ApplicationModel(
      sourceListMapped,
      password,
    );
  }

  SourceSeedModel createSource(
      List<String> mnemonic, String publicKeyTestnet, String publicKeyMainnet, String password) {
    var source = new SourceSeedModel(
        sourceName: SourceName.seed,
        publicKeyMainnet: publicKeyMainnet,
        publicKeyTestnet: publicKeyTestnet,
        password: password,
        mnemonic: mnemonic);
    sourceList[source.id] = source;
    return source;
  }
}
