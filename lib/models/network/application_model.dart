import 'package:crypt/crypt.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class ApplicationModel {
  final Map<String, SourceSeedModel> sourceList;
  late String password;
  late List<AbstractNetworkModel> networks;
  late List<AbstractAccountModel> accounts;
  late AbstractNetworkModel? activeNetwork;
  late AbstractAccountModel? activeAccount;
  late TokenModel? activeToken;

  ApplicationModel({
    required this.sourceList,
    String? password,
    String? encryptedPassword,
    List<AbstractAccountModel>? accounts,
    AbstractNetworkModel? activeNetwork,
    AbstractAccountModel? activeAccount,
    TokenModel? activeToken,
  }) {
    if(password != null){
      this.password = encryptPassword(password);

    } else if(encryptedPassword != null){
      this.password = encryptedPassword;
    } else {
      throw 'Password is required';
    }
    this.networks = ApplicationModel.initNetworks();
    this.accounts = accounts ?? [];

    if (activeNetwork == null) {
      this.activeNetwork = this.networks[0];
    } else {
      this.activeNetwork = activeNetwork;
    }
    this.activeAccount = activeAccount;
    // TODO: need to create list with available tokens for converting
    this.activeToken = TokenModel(
      id: '0',
      symbol: 'USDT',
      name: 'USDT',
      displaySymbol: 'USDT',
      networkName: this.activeNetwork!.networkType.networkName,
    );
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

  static List<AbstractNetworkModel> initNetworks(){
    return [
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainMainnet,
          networkString: 'mainnet',
          isTestnet: false)),
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainTestnet,
          networkString: 'testnet',
          isTestnet: true)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: 'mainnet',
          isTestnet: false)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: 'testnet',
          isTestnet: true))
    ];
  }

  Map<String, dynamic> toJSON() {
    return {
      'sourceList': sourceList.map((key, value) => MapEntry(key, value.toJSON())),
      'password': password,
      'activeAccount': activeAccount!.toJson(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'activeNetwork': activeNetwork!.toJson(),
    };
  }

  factory ApplicationModel.fromJSON(Map<String, dynamic> json) {
    var savedNetwork = NetworkTypeModel.fromJson(
      json['activeNetwork']['networkType'],
    );
    var networks = ApplicationModel.initNetworks();
    final sourceList = json['sourceList'] as Map<String, dynamic>;
    final password = json['password'] as String;
    final activeAccount = AccountModel.fromJson(json['activeAccount'], networks);
    final activeNetwork = networks.firstWhere(
      (element) => element.networkType.networkName == savedNetwork.networkName,
    );
    final accounts = (json['accounts'] as List).map((data) => AccountModel.fromJson(data, networks))
        .toList();

    final sourceListMapped = sourceList.map(
          (key, value) => MapEntry(key, SourceSeedModel.fromJSON(value)),
    );

    return ApplicationModel(
      sourceList: sourceListMapped,
      encryptedPassword: password,
      accounts: accounts,
      activeAccount: activeAccount,
      activeNetwork: activeNetwork,
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

  ApplicationModel copyWith({
    Map<String, SourceSeedModel>? sourceList,
    String? password,
    String? encryptedPassword,
    AbstractNetworkModel? activeNetwork,
  }) {
    return ApplicationModel(
      sourceList: sourceList!,
      password: password,
      encryptedPassword: encryptedPassword,
      activeNetwork: activeNetwork,
    );
  }
}
