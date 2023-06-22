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
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/bitcoin/blockcypher_requests.dart';
import 'package:defi_wallet/services/bitcoin/btc_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;

class BitcoinNetworkModel extends AbstractNetworkModel {
  BitcoinNetworkModel(NetworkTypeModel networkType)
      : super(_validationNetworkName(networkType));

  static const int DUST = 3000;
  static const int FEE = 3000;
  static const int RESERVED_BALANCES = 30000;

  static NetworkTypeModel _validationNetworkName(NetworkTypeModel networkType) {
    if (networkType.networkName != NetworkName.bitcoinTestnet &&
        networkType.networkName != NetworkName.bitcoinMainnet) {
      throw 'Invalid network';
    }
    return networkType;
  }

  factory BitcoinNetworkModel.fromJson(Map<String, dynamic> json) {
    return BitcoinNetworkModel(
      NetworkTypeModel.fromJson(json['networkType']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['networkType'] = this.networkType.toJson();
    return data;
  }

  String createAddress(String publicKey, int accountIndex) {
    var test = _getNetworkTypeBip32();
    var publicKeypair = bip32.BIP32.fromBase58(publicKey, test);
    return this._createAddressString(publicKeypair, accountIndex);
  }

  TokenModel getDefaultToken() {
    return TokenModel(
      isUTXO: true,
      name: 'Bitcoin',
      symbol: 'BTC',
      displaySymbol: 'BTC',
      id: '-1',
      networkName: this.networkType.networkName,
    );
  }

  Future<BalanceModel> getBalanceUTXO(
    List<BalanceModel> balances,
    String addressString,
  ) async {
    int balance = await BlockcypherRequests.getBalance(
      network: this,
      addressString: addressString,
    );

    BalanceModel balanceModel = BalanceModel(
      token: getDefaultToken(),
      balance: balance,
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

  List<HistoryModel> getHistory(String networkName, String? txid) {
    return [];
  }

  List<AbstractOnOffRamp> getRamps() {
    return [];
  }

  List<AbstractBridge> getBridges() {
    throw 'Not works yet';
  }

  List<AbstractExchangeModel> getExchanges() {
    throw 'Bitcoin network does not support exchanges';
  }

  List<AbstractStakingProviderModel> getStakingProviders() {
    throw 'Bitcoin network does not support staking';
  }

  List<AbstractLmProviderModel> getLmProviders() {
    throw 'Bitcoin network does not support LM';
  }

  Future<List<TokenModel>> getAvailableTokens() async {
    throw 'Bitcoin network does not support tokens';
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
      return fromSatoshi(balances[0].balance);
    } else {
      var balance = await getBalanceUTXO(
          balances, account.getAddress(this.networkType.networkName)!);

      account.pinToken(balance, this);

      return fromSatoshi(balance.balance);
    }
  }

  Future<double> getAvailableBalance(
      {required AbstractAccountModel account,
      required TokenModel token,
      TxType type = TxType.send,
      int satPerByte = 0}) async {
    if (satPerByte == 0) {
      var networkFee = await BlockcypherRequests.getNetworkFee(this);
      satPerByte = networkFee.medium!;
    }
    var balance = await this.getBalance(account: account, token: token);
    var utxoList = await BlockcypherRequests.getUTXOs(
      network: this,
      addressString: account.getAddress(this.networkType.networkName)!,
    );
    var fee = fromSatoshi(
        BTCTransactionService.calculateBTCFee(utxoList.length, 1, satPerByte));
    var available = balance - fee;
    return available > 0 ? available : 0;
  }

  bool checkAddress(String address) {
    return Address.validateAddress(
      address,
      getNetworkType(),
    );
  }

  Future<ECPair> getKeypair(String password, AbstractAccountModel account,
      ApplicationModel applicationModel) async {
    var mnemonic =
        applicationModel.sourceList[account.sourceId]!.getMnemonic(password);
    var masterKey = getMasterKeypairFormMnemonic(mnemonic);
    return _getKeypairForPathPrivateKey(masterKey, account.accountIndex);
  }

  Future<NetworkFeeModel> getNetworkFee() async {
    return await BlockcypherRequests.getNetworkFee(this);
  }

  Future<TxErrorModel> send(
      {required AbstractAccountModel account,
      required String address,
      required String password,
      required TokenModel token,
      required double amount,
      required ApplicationModel applicationModel,
      int satPerByte = 0}) async {
    if (satPerByte == 0) {
      var networkFee = await BlockcypherRequests.getNetworkFee(this);
      satPerByte = networkFee.medium!;
    }
    ECPair keypair = await getKeypair(password, account, applicationModel);

    List<BalanceModel> balances = account.getPinnedBalances(this);

    return BTCTransactionService.createSendTransaction(
        senderAddress: account.getAddress(this.networkType.networkName)!,
        keyPair: keypair,
        balance: balances[0],
        destinationAddress: address,
        network: this,
        amount: toSatoshi(amount),
        satPerByte: satPerByte);
  }

  Future<String> signMessage(AbstractAccountModel account, String message,
      String password, ApplicationModel applicationModel) async {
    ECPair keypair = await getKeypair(password, account, applicationModel);

    return keypair.signMessage(message, getNetworkType());
  }

  String _createAddressString(bip32.BIP32 masterKeyPair, int accountIndex) {
    final keyPair = _getKeypairForPathPublicKey(masterKeyPair, accountIndex);
    return _getAddressFromKeyPair(keyPair);
  }

  NetworkType getNetworkType() {
    return this.networkType.isTestnet ? networks.testnet : networks.bitcoin;
  }

  // private

  ECPair _getKeypairForPathPublicKey(bip32.BIP32 masterKeypair, int account) {
    return ECPair.fromPublicKey(
        masterKeypair.derivePath(_derivePath(account)).publicKey,
        network: getNetworkType());
  }

  ECPair _getKeypairForPathPrivateKey(
    bip32.BIP32 masterKeypair,
    int account,
  ) {
    return ECPair.fromPrivateKey(
        masterKeypair.derivePath(_derivePath(account)).privateKey!,
        network: getNetworkType());
  }

  String _derivePath(int account) {
    return "1129/0/0/$account";
  }

  bip32.BIP32 getMasterKeypairFormMnemonic(List<String> mnemonic) {
    final seed = mnemonicToSeed(mnemonic.join(' '));
    return bip32.BIP32.fromSeedWithCustomKey(
        seed, "@defichain/jellyfish-wallet-mnemonic", _getNetworkTypeBip32());
  }

  String _getAddressFromKeyPair(ECPair keyPair) {
    return P2WPKH(
      data: PaymentData(
        pubkey: keyPair.publicKey,
      ),
      network: getNetworkType(),
    ).data!.address!;
  }

  bip32.NetworkType _getNetworkTypeBip32() {
    var network = getNetworkType();
    return bip32.NetworkType(
      bip32: bip32.Bip32Type(
        private: network.bip32.private,
        public: network.bip32.public,
      ),
      wif: network.wif,
    );
  }
}
