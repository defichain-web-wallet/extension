import 'dart:convert';
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
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_token_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/services/ethereum/eth_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defichaindart/src/models/networks.dart' as networks;

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'package:bip32/bip32.dart' as bip32;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math' as Math;

import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:flutter/services.dart' show rootBundle;

class EthereumNetworkModel extends AbstractNetworkModel {
  String rpcUrl;
  List<EthereumTokenModel> popularTokens;

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
        (index) => EthereumTokenModel.fromJSON(json['popularTokens'][index]),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['networkType'] = this.networkType.toJson();
    data['rpcUrl'] = this.rpcUrl;
    data['popularTokens'] = this.popularTokens.map((e) => e.toJson()).toList();
    return data;
  }

  String createAddress(String publicKey, int accountIndex) {
    var publicKeypair = bip32.BIP32.fromBase58(publicKey);
    return this._createAddressString(publicKeypair, accountIndex);
  }

  TokenModel getDefaultToken() {
    return TokenModel(
      isUTXO: true,
      name: 'Ethereum',
      symbol: 'ETH',
      displaySymbol: 'ETH',
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
      balance: balance.getInEther.toInt(), //TODO: fix it before production
    );
    return balanceModel;
  }

  Future<List<BalanceModel>> getAllBalances({
    required String addressString,
  }) async {
    var balance = await getBalanceUTXO([], addressString);

    return [balance];
  }

  Future<BalanceModel> getBalanceToken(
    List<BalanceModel> balances,
    TokenModel token,
    String addressString,
  ) {
    throw 'Bitcoin network does not support tokens';
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
    throw 'Ethereum network does not support tokens';
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
    if (balances.length > 0) {
      return fromSatoshi(balances[0].balance,
          decimals: (token as EthereumTokenModel).tokenDecimals);
    } else {
      var balance = await getBalanceUTXO(
          balances, account.getAddress(this.networkType.networkName)!);

      account.pinToken(balance, this);

      return fromSatoshi(balance.balance,
          decimals: (token as EthereumTokenModel).tokenDecimals);
    }
  }

  Future<double> getAvailableBalance(
      {required AbstractAccountModel account,
      required TokenModel token,
      TxType type = TxType.send}) async {
    // if (satPerByte == 0) {
    //   var networkFee = await BlockcypherRequests.getNetworkFee(this);
    //   satPerByte = networkFee.medium!;
    // }
    // var balance = await this.getBalance(account: account, token: token);
    // var utxoList = await BlockcypherRequests.getUTXOs(
    //   network: this,
    //   addressString: account.getAddress(this.networkType.networkName)!,
    // );
    // var fee = fromSatoshi(
    //     BTCTransactionService.calculateBTCFee(utxoList.length, 1, satPerByte));
    // var available = balance - fee;
    // return available > 0 ? available : 0;
    return 0;
  }

  bool checkAddress(String address) {
    return Address.validateAddress(
      address,
      getNetworkType(),
    );
  }

  Future<EthPrivateKey> getKeypair(String password,
      AbstractAccountModel account, ApplicationModel applicationModel) async {
    var mnemonic =
        applicationModel.sourceList[account.sourceId]!.getMnemonic(password);
    var masterKey = getMasterKeypairFormMnemonic(mnemonic);
    return _getEthPrivateKeyForPathPrivateKey(masterKey, account.accountIndex);
  }

  Future<NetworkFeeModel> getNetworkFee() async {
    final client = Web3Client(this.rpcUrl, Client());
    final gasPrice = await client.getGasPrice();
    final gasEstimate = await client.estimateGas();
    return EthereumNetworkFeeModel(
        gasPrice: gasPrice.getInWei.toInt(), gasLimit: gasEstimate.toInt());
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
    String senderAddress = account.getAddress(this.networkType.networkName)!;
    return ETHTransactionService.createSendTransaction(
      amount: toSatoshi(amount,
          decimals: (token as EthereumTokenModel).tokenDecimals),
      credentials: keypair,
      destinationAddress: address,
      rpcUrl: 'https://eth.llamarpc.com',
      senderAddress: senderAddress,
      maxGas: maxGas,
      gasPrice: gasPrice,
    );
  }

  int toSatoshi(double amount, {int decimals = 16}) =>
      (amount * Math.pow(10, decimals)).round();

  double fromSatoshi(int amount, {int decimals = 16}) =>
      amount / (Math.pow(10, decimals));

  Future<EthereumTokenModel> getTokenByContractAddress(
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

    return EthereumTokenModel(
        id: contractAddress,
        contractAddress: contractAddress,
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

  String _createAddressString(bip32.BIP32 masterKeyPair, int accountIndex) {
    final keyPair = _getKeypairForPathPublicKey(masterKeyPair, accountIndex);
    return _getAddressFromPrivateKey(keyPair);
  }

  NetworkType getNetworkType() {
    return this.networkType.isTestnet ? networks.testnet : networks.bitcoin;
  }

  // private

  EthPrivateKey _getKeypairForPathPublicKey(
      bip32.BIP32 masterKeypair, int account) {
    return EthPrivateKey.fromInt(_bytesToBigInt(
        masterKeypair.derivePath(_derivePath(account)).publicKey));
  }

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
