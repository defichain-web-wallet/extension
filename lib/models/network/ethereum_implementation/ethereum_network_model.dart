import 'dart:typed_data';

import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_bridge_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_exchange_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_on_off_ramp_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_fee_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/services/ethereum/eth_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'package:bip32/bip32.dart' as bip32;
import 'package:http/http.dart';
import 'dart:math' as Math;

import 'package:flutter/services.dart' show rootBundle;

class EthereumNetworkModel extends AbstractNetworkModel {
  String rpcUrl;
  List<TokenModel> popularTokens;

  EthereumNetworkModel(
      NetworkTypeModel networkType, this.rpcUrl, this.popularTokens)
      : super(_validationNetworkName(networkType));

  static NetworkTypeModel _validationNetworkName(NetworkTypeModel networkType) {
    if (networkType.networkName != NetworkName.ethereumTestnet &&
        networkType.networkName != NetworkName.ethereumMainnet) {
      throw 'Invalid network';
    }
    return networkType;
  }

  factory EthereumNetworkModel.fromJson(Map<String, dynamic> json) {
    return EthereumNetworkModel(
      NetworkTypeModel.fromJson(json['networkType']),
      json['rpcUrl'],
      List.generate(
        json['popularTokens'].length,
        (index) => TokenModel.fromJSON(json['popularTokens'][index]),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['networkType'] = this.networkType.toJson();
    data['rpcUrl'] = this.rpcUrl;
    data['popularTokens'] = this.popularTokens.map((e) => e.toJSON()).toList();
    return data;
  }

  @deprecated
  String createAddress(String publicKey, int accountIndex) {
    throw 'Use createAddressFromPrivateKey';
  }

  Future<String> createAddressFromPrivateKey(int accountIndex, String password, SourceSeedModel source) async {
    final keypair = await getKeypairWithoutAccount(password,
        accountIndex, source);
    return this._createAddressString(keypair, accountIndex);
  }

  TokenModel getDefaultToken() {
    return TokenModel(
      isUTXO: true,
      name: 'Ethereum',
      symbol: 'ETH',
      displaySymbol: 'ETH',
      tokenDecimals: 18,
      id: '-1',
      networkName: this.networkType.networkName,
    );
  }

  Future<BalanceModel> getBalanceUTXO(
    List<BalanceModel> balances,
    String addressString,
  ) async {
    final client = Web3Client(this.rpcUrl, Client());
    var balance =
        await client.getBalance(EthereumAddress.fromHex(addressString));
    BalanceModel balanceModel = BalanceModel(
      token: getDefaultToken(),
      balance: balance.getInWei.toInt(), //TODO: fix it before production
    );
    return balanceModel;
  }

  Future<BalanceModel> getBalanceToken(
    List<BalanceModel> balances,
    TokenModel token,
    String addressString,
  ) async {
    return balances
        .where((element) => element.token != null)
        .firstWhere((element) => element.token!.compare(token));
  }

  Future<List<BalanceModel>> getAllBalances({
    required String addressString,
    AbstractAccountModel? account,
  }) async {
    List<BalanceModel> balances = [];
    var balanceUtxo = await getBalanceUTXO([], addressString);
    balances.add(balanceUtxo);
    if (account != null) {
      List<BalanceModel> oldBalances = account.getPinnedBalances(this);
      print(oldBalances.length);

      final client = Web3Client(this.rpcUrl, Client());
      final jsonString =
          await rootBundle.loadString('assets/abi/erc20_abi.json');
      final contractAbi = ContractAbi.fromJson(jsonString, 'Token');
      for (var balance in oldBalances) {
        if (!balance.token!.isUTXO) {
          final contractAddress = EthereumAddress.fromHex(
              balance.token!.id);
          final contract = DeployedContract(
            contractAbi,
            contractAddress,
          );

          // Get the balance
          final function = contract.function('balanceOf');
          final List<dynamic> result = await client.call(
            contract: contract,
            function: function,
            params: [EthereumAddress.fromHex(addressString)],
          );
          balance.balance = result.first.toInt();

          balances.add(balance);
        }
      }
    }

    return balances;
  }

  bool isTokensPresent() {
    return false;
  }

  bool isGas() {
    return true;
  }

  List<HistoryModel> getHistory(String networkName, String? txid) {
    return [];
  }

  List<AbstractOnOffRamp> getRamps() {
    return [];
  }

  List<AbstractBridge> getBridges() {
    return [];
  }

  List<AbstractExchangeModel> getExchanges() {
    throw 'Ethereum network does not support exchanges';
  }

  List<AbstractStakingProviderModel> getStakingProviders() {
    throw 'Ethereum network does not support staking';
  }

  List<AbstractLmProviderModel> getLmProviders() {
    throw 'Ethereum network does not support LM';
  }

  Future<List<TokenModel>> getAvailableTokens() async {
    return this.popularTokens;
  }

  Uri getTransactionExplorer(String tx) {
    final network = this.networkType.isTestnet ? 'btc-testnet' : 'btc';

    return Uri.https(Hosts.blockcypherHome, '$network/tx/$tx');
  }

  Uri getAccountExplorer(String address) {
    final network = this.networkType.isTestnet ? 'btc-testnet' : 'btc';

    return Uri.https(Hosts.blockcypherHome, '$network/address/$address');
  }

  Future<double> getBalance({
    required AbstractAccountModel account,
    required TokenModel token,
  }) async {
    List<BalanceModel> balances = account.getPinnedBalances(this);
    var balance = await this.getBalanceToken(balances, token, '');
    return this.fromSatoshi(balance.balance, decimals: token.tokenDecimals);
  }

  Future<double> getAvailableBalance(
      {required AbstractAccountModel account,
      required TokenModel token,
      TxType type = TxType.send,
      EthereumNetworkFeeModel? fee}) async {
    try {
      var balance = await this.getBalance(account: account, token: token);
      if (token.isUTXO) {
        if (fee == null) {
          fee = (await this.getNetworkFee() as EthereumNetworkFeeModel);
        }
        balance = fromSatoshi(toSatoshi(balance) -
            toSatoshi(calculateFee(fee.gasPrice!, fee.gasLimit!)));
        return balance < 0 ? 0 : balance;
      } else {
        return balance < 0 ? 0 : balance;
      }
    } catch (e) {
      print(e);
      return 0;
    }
  }

  double calculateFee(int gasPrice, int gasLimit) {
    final gasPriceInWei = gasPrice! * 1000000000;
    final totalGasFeeInWei = gasPriceInWei * gasLimit!;
    return totalGasFeeInWei * 0.000000000000000001;
  }

  bool checkAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<EthPrivateKey> getKeypair(String password,
      AbstractAccountModel account, ApplicationModel applicationModel) async {
    var mnemonic =
        applicationModel.sourceList[account.sourceId]!.getMnemonic(password);
    var masterKey = getMasterKeypairFormMnemonic(mnemonic);
    return _getEthPrivateKeyForPathPrivateKey(masterKey, account.accountIndex);
  }

  Future<EthPrivateKey> getKeypairWithoutAccount(String password,
      int accountIndex, SourceSeedModel source) async {
    var mnemonic =
    source.getMnemonic(password);
    var masterKey = getMasterKeypairFormMnemonic(mnemonic);
    return _getEthPrivateKeyForPathPrivateKey(masterKey, accountIndex);
  }

  Future<NetworkFeeModel> getNetworkFee({TokenModel? token}) async {
    final client = Web3Client(this.rpcUrl, Client());
    final gasPrice = await client.getGasPrice();
    var gasEstimate = 21000;
    if(token != null){ //TODO: need to find
      if(!token.isUTXO){
        gasEstimate = 50000;
      }
    }

    return EthereumNetworkFeeModel(
        gasPrice: gasPrice.getValueInUnit(EtherUnit.gwei).toInt(),
        gasLimit: gasEstimate);
  }

  Future<TxErrorModel> send(
      {required AbstractAccountModel account,
      required String address,
      required String password,
      required TokenModel token,
      required double amount,
      required ApplicationModel applicationModel,
      int satPerByte = 0,
      int gasPrice = 0,
      int maxGas = 0}) async {
    EthPrivateKey keypair =
        await getKeypair(password, account, applicationModel);
    DeployedContract? contract;
    if (!token.isUTXO) {
      final jsonString =
          await rootBundle.loadString('assets/abi/erc20_abi.json');
      final contractAddress = EthereumAddress.fromHex(
          token.id);
      final contractAbi = ContractAbi.fromJson(jsonString, 'Token');
      contract = DeployedContract(
        contractAbi,
        contractAddress,
      );
    }
    String senderAddress = account.getAddress(this.networkType.networkName)!;
    return ETHTransactionService.createSendTransaction(
        amount: toSatoshi(
          amount,
          decimals: token.tokenDecimals,
        ),
        credentials: keypair,
        destinationAddress: address,
        rpcUrl: rpcUrl,
        senderAddress: senderAddress,
        maxGas: maxGas,
        gasPrice: gasPrice,
        contract: contract);
  }

  int toSatoshi(double amount, {int decimals = 16}) =>
      (amount * Math.pow(10, decimals)).round();

  double fromSatoshi(int amount, {int decimals = 16}) =>
      amount / (Math.pow(10, decimals));

  Future<TokenModel> getTokenByContractAddress(
      String contractAddress) async {
    final client = Web3Client(this.rpcUrl, Client());

    final jsonString = await rootBundle.loadString('assets/abi/erc20_abi.json');
    final address = EthereumAddress.fromHex(contractAddress);
    final contractAbi = ContractAbi.fromJson(jsonString, 'Token');
    final contract = DeployedContract(
      contractAbi,
      address,
    );

    // Get token name
    final symbolFunction = contract.function('symbol');
    final symbolResponse = await client
        .call(contract: contract, function: symbolFunction, params: []);
    final tokenSymbol = symbolResponse[0].toString();

    // Get token decimals
    final decimalsFunction = contract.function('decimals');
    final decimalsResponse = await client
        .call(contract: contract, function: decimalsFunction, params: []);
    final tokenDecimals = int.parse(decimalsResponse[0].toString());

    // Get token name
    final nameFunction = contract.function('name');
    final nameResponse = await client
        .call(contract: contract, function: nameFunction, params: []);
    final tokenName = nameResponse[0].toString();

    return TokenModel(
        id: contractAddress,
        symbol: tokenSymbol,
        name: tokenName,
        displaySymbol: tokenSymbol,
        tokenDecimals: tokenDecimals,
        networkName: this.networkType.networkName);
  }

  Future<String> signMessage(AbstractAccountModel account, String message,
      String password, ApplicationModel applicationModel) async {
    final keypair = await getKeypair(password, account, applicationModel);
    final messageBytes = Uint8List.fromList(message.codeUnits);
    final signature = keypair.signPersonalMessageToUint8List(messageBytes);
    return bytesToHex(signature, include0x: true);
  }

  String _createAddressString(EthPrivateKey masterKeyPair, int accountIndex) {
    return _getAddressFromPrivateKey(masterKeyPair);
  }

  // private

  EthPrivateKey _getEthPrivateKeyForPathPrivateKey(
    bip32.BIP32 masterKeypair,
    int account,
  ) {
    return EthPrivateKey.fromInt(_bytesToBigInt(
        masterKeypair.derivePath(_derivePath(account)).privateKey!));
  }

  String _derivePath(int account) {
    return 'm/0/$account';
  }

  bip32.BIP32 getMasterKeypairFormMnemonic(List<String> mnemonic) {
    final seed = mnemonicToSeed(mnemonic.join(' '));
    return bip32.BIP32.fromSeed(seed);
  }

  String _getAddressFromPrivateKey(EthPrivateKey credentials) {
    return credentials.address.hex;
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    // Convert the Uint8List to a hexadecimal String
    String hexString =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    // Parse the hexadecimal String to BigInt
    return BigInt.parse(hexString, radix: 16);
  }
}
