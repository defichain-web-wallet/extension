import 'package:crypt/crypt.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
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

  List<AbstractNetworkModel> getNetworks({required bool isTestnet}) {
    return networks
        .where((element) => isTestnet == element.networkType.isTestnet)
        .toList();
  }

  static List<AbstractNetworkModel> initNetworks() {
    return [
      DefichainNetworkModel(
        NetworkTypeModel(
          networkName: NetworkName.defichainMainnet,
          networkString: 'mainnet',
          isTestnet: false,
        ),
      ),
      DefichainNetworkModel(
        NetworkTypeModel(
          networkName: NetworkName.defichainTestnet,
          networkString: 'testnet',
          isTestnet: true,
        ),
      ),
      BitcoinNetworkModel(
        NetworkTypeModel(
          networkName: NetworkName.bitcoinMainnet,
          networkString: 'mainnet',
          isTestnet: false,
        ),
      ),
      BitcoinNetworkModel(
        NetworkTypeModel(
          networkName: NetworkName.bitcoinTestnet,
          networkString: 'testnet',
          isTestnet: true,
        ),
      ),
      EthereumNetworkModel(
        NetworkTypeModel(
          networkName: NetworkName.ethereumMainnet,
          networkString: 'mainnet',
          isTestnet: false,
        ),
        'https://eth.llamarpc.com',
        _getEthereumMainnetTokens(),
      ),
      EthereumNetworkModel(
        NetworkTypeModel(
          networkName: NetworkName.ethereumTestnet,
          networkString: 'testnet',
          isTestnet: true,
        ),
        'https://endpoints.omniatech.io/v1/eth/sepolia/public',
        _getEthereumTestnetTokens(),
      ),
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
    final networks = List.generate(
      networksListJson.length,
          (index) {
        final network = networksListJson[index];
        if (network['networkType']['networkName'].contains('defichain')) {
          return DefichainNetworkModel.fromJson(network);
        } else if (network['networkType']['networkName'].contains('eth')) {
          return EthereumNetworkModel.fromJson(network);
        } else {
          return BitcoinNetworkModel.fromJson(network);
        }
      },
    );
    final savedNetwork = NetworkTypeModel.fromJson(
      json['activeNetwork']['networkType'],
    );
    final sourceList = json['sourceList'] as Map<String, dynamic>;
    final password = json['password'] as String;
    final activeAccount = AccountModel.fromJson(
      json['activeAccount'],
      networks,
    );
    final activeNetwork = networks.firstWhere(
          (element) => element.networkType.networkName == savedNetwork.networkName,
    );
    final accounts = (json['accounts'] as List)
        .map((json) => AccountModel.fromJson(json, networks))
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
    )..networks = networks;
  }

  List<String> getMnemonic(String password) {
    return this.sourceList[this.activeAccount!.sourceId]!.getMnemonic(password);
  }

  SourceSeedModel createSource(
      List<String> mnemonic,
      String publicKeyTestnet,
      String publicKeyMainnet,
      String password,
      ) {
    SourceSeedModel source = SourceSeedModel(
      sourceName: SourceName.seed,
      publicKeyMainnet: publicKeyMainnet,
      publicKeyTestnet: publicKeyTestnet,
      password: password,
      mnemonic: mnemonic,
    );
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

  static List<TokenModel> _getEthereumMainnetTokens() {
    return [
      TokenModel(
        id: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
        tokenDecimals: 6,
        displaySymbol: 'USDT',
        symbol: 'USDT',
        name: 'Tether USD',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
        tokenDecimals: 6,
        displaySymbol: 'USDC',
        symbol: 'USDC',
        name: 'USD Coin',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x1f9840a85d5af5bf1d1762f925bdaddc4201f984',
        tokenDecimals: 18,
        displaySymbol: 'UNI',
        symbol: 'UNI',
        name: 'Uniswap',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x75231f58b43240c9718dd58b4967c5114342a86c',
        tokenDecimals: 18,
        displaySymbol: 'OKB',
        symbol: 'OKB',
        name: 'OKB',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x582d872a1b094fc48f5de31d3b73f2d9be47def1',
        tokenDecimals: 9,
        displaySymbol: 'TONCOIN',
        symbol: 'TONCOIN',
        name: 'Wrapped TON Coin',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x514910771af9ca656af840dff83e8264ecf986ca',
        tokenDecimals: 18,
        displaySymbol: 'LINK',
        symbol: 'LINK',
        name: 'ChainLink Token',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0',
        tokenDecimals: 18,
        displaySymbol: 'MATIC',
        symbol: 'MATIC',
        name: 'Matic Token',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x6b175474e89094c44da98b954eedeac495271d0f',
        tokenDecimals: 18,
        displaySymbol: 'DAI',
        symbol: 'DAI',
        name: 'Dai Stablecoin',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0xae7ab96520de3a18e5e111b5eaab095312d7fe84',
        tokenDecimals: 18,
        displaySymbol: 'stETH',
        symbol: 'stETH',
        name: 'Liquid staked Ether 2.0',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599',
        tokenDecimals: 8,
        displaySymbol: 'WBTC',
        symbol: 'WBTC',
        name: 'Wrapped BTC',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x95ad61b0a150d79219dcf64e1e6cc01f0b64c4ce',
        tokenDecimals: 18,
        displaySymbol: 'SHIB',
        symbol: 'SHIB',
        name: 'SHIBA INU',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9',
        tokenDecimals: 18,
        displaySymbol: 'AAVE',
        symbol: 'AAVE',
        name: 'Aave Token',
        networkName: NetworkName.ethereumMainnet,
      ),
      TokenModel(
        id: '0xF04f22b39bF419FdEc8eAE7C69c5E89872915f53',
        tokenDecimals: 18,
        displaySymbol: 'DASH',
        symbol: 'DASH',
        name: 'Dash',
        networkName: NetworkName.ethereumMainnet,
      ),
    ];
  }

  static List<TokenModel> _getEthereumTestnetTokens() {
    return [
      TokenModel(
        id: '0x36160274B0ED3673E67F2CA5923560a7a0c523aa',
        tokenDecimals: 18,
        displaySymbol: 'USDT',
        symbol: 'USDT',
        name: 'Tether',
        networkName: NetworkName.ethereumTestnet,
      ),
      TokenModel(
        id: '0x2B0974b96511a728CA6342597471366D3444Aa2a',
        tokenDecimals: 6,
        displaySymbol: 'USDC',
        symbol: 'USDC',
        name: 'USDC',
        networkName: NetworkName.ethereumTestnet,
      ),
      TokenModel(
        id: '0x3B0067071CEC666bFE51DDff78F07541aebef3EE',
        tokenDecimals: 18,
        displaySymbol: 'DASH',
        symbol: 'DASH',
        name: 'Dash',
        networkName: NetworkName.ethereumTestnet,
      ),
      TokenModel(
        id: '0x82fb927676b53b6eE07904780c7be9b4B50dB80b',
        tokenDecimals: 18,
        displaySymbol: 'DAI',
        symbol: 'DAI',
        name: 'DAI',
        networkName: NetworkName.ethereumTestnet,
      ),
      TokenModel(
        id: '0x1f9840a85d5af5bf1d1762f925bdaddc4201f984',
        tokenDecimals: 18,
        displaySymbol: 'UNI',
        symbol: 'UNI',
        name: 'Uniswap',
        networkName: NetworkName.ethereumTestnet,
      ),
      TokenModel(
        id: '0x804F2160ca8F886B0c06c2290ACfDb5a31AA32b5',
        tokenDecimals: 18,
        displaySymbol: 'OKB',
        symbol: 'OKB',
        name: 'OKB',
        networkName: NetworkName.ethereumTestnet,
      ),
    ];
  }
}
