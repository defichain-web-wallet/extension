import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_bridge_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_exchange_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_on_off_ramp_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_exchange_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_lm_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_balance_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_token_requests.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;

class DefichainNetworkModel extends AbstractNetworkModel {
  DefichainNetworkModel(NetworkTypeModel networkType)
      : super(_validationNetworkName(networkType));

  static const int DUST = 3000;
  static const int FEE = 3000;
  static const int RESERVED_BALANCES = 30000;

  static NetworkTypeModel _validationNetworkName(NetworkTypeModel networkType) {
    if (networkType.networkName != NetworkName.defichainTestnet &&
        networkType.networkName != NetworkName.defichainMainnet) {
      throw 'Invalid network';
    }
    return networkType;
  }

  Future<List<TokenModel>> getAvailableTokens() async {
    return await DFITokenRequests.getTokens(networkType: this.networkType);
  }

  List<HistoryModel> getHistory(String networkName, String? txid) {
    return [];
  }

  List<AbstractOnOffRamp> getRamps() {
    return [];
  }

  Uri getTransactionExplorer(String tx) {
    final query = {
      'network': networkType.networkStringLowerCase,
    };

    return Uri.https(Hosts.defiScanHome, '/transactions/$tx', query);
  }

  Uri getAccountExplorer(String address) {
    final query = {
      'network': networkType.networkStringLowerCase,
    };

    return Uri.https(Hosts.defiScanHome, '/address/$address', query);
  }

  List<AbstractBridge> getBridges() {
    throw 'Not works yet';
  }

  List<AbstractExchangeModel> getExchanges() {
    return [DefichainExchangeModel()];
  }

  List<AbstractStakingProviderModel> getStakingProviders() {
    return [];
  }

  List<AbstractLmProviderModel> getLmProviders() {
    return [DefichainLmProviderModel()];
  }

  Future<double> getBalance({
    required AbstractAccountModel account,
    required TokenModel token,
  }) async {
    List<BalanceModel> balances = account.getPinnedBalances(this);
    late BalanceModel balance;

    if (token.symbol == 'DFI') {
      BalanceModel balanceUTXO = await getBalanceUTXO(
        balances,
        account.getAddress(this.networkType.networkName)!,
      );
      BalanceModel balanceToken = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );
      return fromSatoshi(balanceUTXO.balance + balanceToken.balance);
    } else {
      balance = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );
      return fromSatoshi(balance.balance);
    }
  }

  Future<double> getAvailableBalance({
    required AbstractAccountModel account,
    required TokenModel token,
    required TxType type,
  }) async {
    List<BalanceModel> balances = account.getPinnedBalances(this);

    if (token.symbol == 'DFI') {
      BalanceModel tokenDFIBalance = await getBalanceUTXO(
        balances,
        account.getAddress(this.networkType.networkName)!,
      );
      BalanceModel coinDFIBalance = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );

      switch (type) {
        case TxType.send:
          if (tokenDFIBalance.balance > FEE) {
            return coinDFIBalance.balance + tokenDFIBalance.balance - (FEE * 2);
          } else {
            return fromSatoshi(coinDFIBalance.balance - (FEE));
          }
        case TxType.swap:
          if (coinDFIBalance.balance > (FEE * 2) + DUST) {
            return coinDFIBalance.balance + tokenDFIBalance.balance - (FEE * 2);
          } else {
            return fromSatoshi(tokenDFIBalance.balance);
          }
        case TxType.addLiq:
          if (coinDFIBalance.balance > (FEE * 2) + DUST) {
            return coinDFIBalance.balance + tokenDFIBalance.balance - (FEE * 2);
          } else {
            return fromSatoshi(tokenDFIBalance.balance);
          }
        default:
          return 0;
      }
    } else {
      BalanceModel balance = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );
      return fromSatoshi(balance.balance);
    }
  }

  bool checkAddress(String address) {
    return Address.validateAddress(
      address,
      _getNetworkType(),
    );
  }

  Future<ECPair> getKeypair(String password, int accountIndex) async {
    String masterKey = await HiveService.getMasterKey(
      password,
      this.networkType,
    );

    return _getKeypairForPathPrivateKey(
      bip32.BIP32.fromBase58(masterKey, _getNetworkTypeBip32()),
      accountIndex,
    );
  }

  Future<TxErrorModel> send(
      {required AbstractAccountModel account,
      required String address,
      required String password,
      required TokenModel token,
      required double amount}) async {
    ECPair keypair = await getKeypair(
      password,
      account.accountIndex,
    );

    List<BalanceModel> balances = account.getPinnedBalances(this);
    BalanceModel balanceUTXO = await getBalanceUTXO(
      balances,
      account.getAddress(this.networkType.networkName)!,
    );
    BalanceModel balanceToken = await getBalanceToken(
      balances,
      token,
      account.getAddress(this.networkType.networkName)!,
    );

    return DFITransactionService().createSendTransaction(
      senderAddress: account.getAddress(this.networkType.networkName)!,
      keyPair: keypair,
      balanceUTXO: balanceUTXO,
      balance: balanceToken,
      destinationAddress: address,
      networkString: this.networkType.networkStringLowerCase,
      amount: toSatoshi(amount),
    );
  }

  Future<String> signMessage(
    AbstractAccountModel account,
    String message,
    String password,
  ) async {
    ECPair keypair = await getKeypair(
      password,
      account.accountIndex,
    );

    return keypair.signMessage(message, _getNetworkType());
  }

  Future<BalanceModel> getBalanceUTXO(
    List<BalanceModel> balances,
    String addressString,
  ) async {
    late BalanceModel? balance;
    try {
      balance = balances.firstWhere((element) => element.token!.isUTXO);
    } catch (_) {
      //not realistic case
      balance = await DFIBalanceRequests.getUTXOBalance(
        network: this,
        addressString: addressString,
      );
    }
    return balance;
  }

  Future<BalanceModel> getBalanceToken(
    List<BalanceModel> balances,
    TokenModel token,
    String addressString,
  ) async {
    late BalanceModel? balance;
    try {
      balance = balances.firstWhere((element) => element.token!.compare(token));
    } catch (_) {
      //if not exist in balances we check blockchain
      List<BalanceModel> balanceList = await DFIBalanceRequests.getBalanceList(
        network: this,
        addressString: addressString,
      );
      try {
        balance = balanceList.firstWhere(
          (element) => element.token!.compare(token),
        );
      } catch (_) {
        //if in blockchain balance doesn't exist - we return 0
        balance = BalanceModel(balance: 0, token: token);
      }
    }
    return balance;
  }

  Future<String> createAddress(
      bip32.BIP32 masterKeyPair, int accountIndex) async {
    final keyPair = _getKeypairForPathPublicKey(masterKeyPair, accountIndex);
    return _getAddressFromKeyPair(keyPair);
  }

  // private
  NetworkType _getNetworkType() {
    return this.networkType.isTestnet
        ? networks.defichain_testnet
        : networks.defichain;
  }

  ECPair _getKeypairForPathPublicKey(bip32.BIP32 masterKeypair, int account) {
    return ECPair.fromPublicKey(
        masterKeypair.derivePath(_derivePath(account)).publicKey,
        network: _getNetworkType());
  }

  ECPair _getKeypairForPathPrivateKey(
    bip32.BIP32 masterKeypair,
    int account,
  ) {
    return ECPair.fromPrivateKey(
        masterKeypair.derivePath(_derivePath(account)).privateKey!,
        network: _getNetworkType());
  }

  String _derivePath(int account) {
    return "1129/0/0/$account";
  }

  Future<String> _getAddressFromKeyPair(ECPair keyPair) async {
    final address = P2WPKH(
      data: PaymentData(
        pubkey: keyPair.publicKey,
      ),
      network: _getNetworkType(),
    ).data!.address;
    return address!;
  }

  bip32.NetworkType _getNetworkTypeBip32() {
    var network = _getNetworkType();
    return bip32.NetworkType(
      bip32: bip32.Bip32Type(
        private: network.bip32.private,
        public: network.bip32.public,
      ),
      wif: network.wif,
    );
  }
}
