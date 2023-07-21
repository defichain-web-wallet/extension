import 'package:crypt/crypt.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_ledger_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/ledger_account_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class ApplicationModel {
  final Map<String, SourceModel> sourceList;
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
    if (password != null) {
      this.password = encryptPassword(password);
    } else if (encryptedPassword != null) {
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

  String encryptPassword(String password) {
    return Crypt.sha256(password).toString();
  }

  bool validatePassword(String password) {
    return Crypt(this.password).match(password);
  }

  List<AbstractNetworkModel> getNetworks(
      {required bool isTestnet, required bool isLocalWallet}) {
    return networks
        .where((element) =>
            isTestnet == element.networkType.isTestnet &&
            isLocalWallet == element.networkType.isLocalWallet)
        .toList();
  }

  static List<AbstractNetworkModel> initNetworks() {
    return [
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainMainnet,
          networkString: 'mainnet',
          isTestnet: false,
          isLocalWallet: true)),
      new DefichainNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.defichainTestnet,
          networkString: 'testnet',
          isTestnet: true,
          isLocalWallet: true)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: 'mainnet',
          isTestnet: false,
          isLocalWallet: true)),
      new BitcoinNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: 'testnet',
          isTestnet: true,
          isLocalWallet: true)),
      new BitcoinLedgerNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: 'mainnet',
          isTestnet: false,
          isLocalWallet: false)),
      new BitcoinLedgerNetworkModel(new NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: 'testnet',
          isTestnet: true,
          isLocalWallet: false))
    ];
  }

  Map<String, dynamic> toJSON() {
    return {
      'sourceList': sourceList.map(
        (key, value) => MapEntry(key, value.toJSON()),
      ),
      'password': password,
      'activeAccount': activeAccount!.toJson(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'activeNetwork': activeNetwork!.toJson(),
      'networks': List.generate(
        networks.length,
        (index) => networks[index].toJson(),
      ),
    };
  }

  factory ApplicationModel.fromJSON(Map<String, dynamic> json) {
    final networksListJson = json['networks'];
    final networks = List.generate(networksListJson.length, (index) {
      final network = networksListJson[index];
      if (network['networkType']['networkName'].contains('defichain')) {
        return DefichainNetworkModel.fromJson(network);
      } else {
        return BitcoinNetworkModel.fromJson(network);
      }
    });
    final savedNetwork = NetworkTypeModel.fromJson(
      json['activeNetwork']['networkType'],
    );
    final sourceList = json['sourceList'] as Map<String, dynamic>;
    final password = json['password'] as String;
    final activeAccount =
        AccountModel.fromJson(json['activeAccount'], networks);
    final activeNetwork = networks.firstWhere(
      (element) => element.networkType.networkName == savedNetwork.networkName,
    );
    final accounts = (json['accounts'] as List).map((accountJson) {
      if (accountJson.containsKey('type')) {
        if (accountJson['type'] == 'ledger') {
          return LedgerAccountModel.fromJson(accountJson, networks);
        }
      }
      return AccountModel.fromJson(accountJson, networks);
    }).toList();

    final sourceListMapped = sourceList.map(
      (key, value) => MapEntry(key, SourceModel.fromJSON(value)),
    );

    return ApplicationModel(
      sourceList: sourceListMapped,
      encryptedPassword: password,
      accounts: accounts,
      activeAccount: activeAccount,
      activeNetwork: activeNetwork,
    )..networks = networks;
  }

  List<String> getMnemonic(String password) {
    var sourceModel = this.sourceList[this.activeAccount!.sourceId];

    if (sourceModel is SourceModel) {
      return sourceModel.getMnemonic(password);
    }
    return [];
  }

  SourceModel createSource(List<String>? mnemonic, String? publicKeyTestnet,
      String? publicKeyMainnet, String password, SourceName sourceName) {
    var source = new SourceModel(
        sourceName: sourceName,
        publicKeyMainnet: publicKeyMainnet,
        publicKeyTestnet: publicKeyTestnet,
        password: password,
        mnemonic: mnemonic);
    sourceList[source.id] = source;
    return source;
  }

  ApplicationModel copyWith({
    Map<String, SourceModel>? sourceList,
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
