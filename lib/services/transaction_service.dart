import 'dart:math';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_auth_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_response_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/btc_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/requests/token_requests.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:defichaindart/defichaindart.dart';

import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';

class TransactionService {
  static const DUST = 1000;
  static const FEE = 3000;
  static const int AuthTxMin = 200000;
  var networkHelper = NetworkHelper();
  var transactionRequests = TransactionRequests();
  var historyRequests = HistoryRequests();
  var balanceRequests = BalanceRequests();
  var balancesHelper = BalancesHelper();
  var tokensRequests = TokenRequests();
  List<UtxoModel> accountUtxoList = [];

  Future<TxErrorModel> removeLiqudity(
      {required AccountModel account,
        required ECPair keyPair,
      required AssetPairModel token,
      required int amount}) async {
    await _getUtxoList(account);

    var responseModel = await createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        account: account,
        destinationAddress: account.addressList![0].address!,
        changeAddress: account.addressList![0].address!,
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txb.addRemoveLiquidityOutput(
              token.id!, amount, account.addressList![0].address!);
        });
    return await _waitPreviousTx(responseModel);
  }

  Future<String> createBTCTransaction({
    required ECPair keyPair,
    required AccountModel account,
    required String destinationAddress,
    required int amount,
    required int satPerByte}) async {
    //romance portion fit sea price casual forward piano afraid erosion want replace excite figure place butter fortune empower rotate safe surface person distance simple
    //https://api.blockcypher.com/v1/btc/test3/addrs/tb1qhwqqsktldqypttltr59px506p890ce0sgj0fe7?unspentOnly=true

    var utxos = await BtcRequests().getUTXOs(address: account.bitcoinAddress!);
    var fee = calculateBTCFee(2,2,satPerByte);
    var selectedUtxo = _utxoSelector(utxos, fee, amount);
    if (selectedUtxo.length > 2){
      selectedUtxo = _utxoSelector(utxos, calculateBTCFee(2,selectedUtxo.length,satPerByte), amount);
    }
    String network = SettingsHelper.settings.network! == 'mainnet' ? 'bitcoin' : 'bitcoin_testnet';
    NetworkType networkType = NetworkHelper().getNetwork(network);
    final _txb = TransactionBuilder(
        network: networkType);
    _txb.setVersion(2);
    var amountUtxo = 0;
    selectedUtxo.forEach((utxo) {
      amountUtxo += utxo.value!;
      _txb.addInput(utxo.mintTxId, utxo.mintIndex, null, P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: networkType).data!.output);
    });

    _txb.addOutput(destinationAddress, amount);
    if(amountUtxo > amount+fee+DUST){
      _txb.addOutput(account.bitcoinAddress!.address, amountUtxo - (amount+fee));
    }
    selectedUtxo.asMap().forEach((index, utxo) {
    _txb.sign(
        vin: index,
        keyPair: keyPair,
        witnessValue: utxo.value);
    });

    return _txb.build().toHex();
  }

  Future<TxErrorModel> createAndSendLiqudity(
      {required AccountModel account,
        required ECPair keyPair,
      required String tokenA,
      required String tokenB,
      required int amountA,
      required int amountB,
      required List<TokensModel> tokens}) async {

    await _getUtxoList(account);

    int? amountDFI;

    if (tokenA == 'DFI') {
      amountDFI = amountA;
    } else if (tokenB == 'DFI') {
      amountDFI = amountB;
    }

    var addressBalanceList = await balanceRequests
        .getAddressBalanceListByAddressList(account.addressList!);

    if(amountDFI != null){
      var tokenDFIbalanceAll =
      balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

      var coinDFIbalanceAll =
      balancesHelper.getBalanceByTokenName(addressBalanceList, '\$DFI');

      if (tokenDFIbalanceAll + coinDFIbalanceAll < amountDFI) {
        return TxErrorModel(isError: true, error: 'Not enough balance. Wait for approval the previous tx');
      }

      var tokenDFIId = await tokensRequests.getTokenID('DFI', tokens);

      if (tokenDFIbalanceAll < amountDFI) {
        var responseModel = await createTransaction(
          keyPair: keyPair,
            utxoList: accountUtxoList,
            account: account,
            destinationAddress: account.addressList![0].address!,
            changeAddress: account.getActiveAddress(isChange: true),
            amount: 0,
            reservedBalance: amountDFI - tokenDFIbalanceAll,
            additional: (txb, nw, newUtxo) {
              txb.addUtxosToAccountOutput(
                  tokenDFIId,
                  account.addressList![0].address!,
                  amountDFI! - tokenDFIbalanceAll,
                  nw);
            });

        var utxoToAccTxid = await _waitPreviousTx(responseModel);
        if (utxoToAccTxid.isError) {
          return utxoToAccTxid;
        }
      }
    }

    var tokenAId = await tokensRequests.getTokenID(tokenA, tokens);
    var tokenBId = await tokensRequests.getTokenID(tokenB, tokens);

    var responseModel = await createTransaction(
      keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: account.addressList![0].address!,
        account: account,
        changeAddress: account.getActiveAddress(isChange: true),
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txb.addAddLiquidityOutputSingleAddress(
              account.addressList![0].address!,
              tokenAId!,
              amountA,
              tokenBId!,
              amountB,
              account.addressList![0].address!);
        },
        useAllUtxo: true);

    return await _waitPreviousTx(responseModel);
  }

  Future<TxErrorModel> createAndSendTransaction(
      {required AccountModel account,
        required ECPair keyPair,
      required String destinationAddress,
      required int amount, required List<TokensModel> tokens}) async {
    var tokenId = await tokensRequests.getTokenID('DFI', tokens);
    TxResponseModel? responseModel;

    await _getUtxoList(account);

    var addressBalanceList = await balanceRequests
        .getAddressBalanceListByAddressList(account.addressList!);
    var tokenDFIbalance =
    balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

    //Swap DFI tokens to UTXO if needed
    if (tokenDFIbalance >= DUST) {
      responseModel = await createTransaction(
          keyPair: keyPair,
          utxoList: accountUtxoList,
          destinationAddress: destinationAddress,
          changeAddress: account.getActiveAddress(isChange: true),
          amount: 0,
          account: account,
          additional: (txb, nw, newUtxo) {
            final mintingStartsAt = txb.tx!.ins.length + 1;
            newUtxo.add(UtxoModel(
                address: account.addressList![0].address!,
                value: tokenDFIbalance,
                mintIndex: newUtxo.length + 1));
            txb.addOutput(account.addressList![0].address!, tokenDFIbalance);
            txb.addAccountToUtxoOutput(tokenId, account.addressList![0].address!,
                tokenDFIbalance, mintingStartsAt);
          });
      if (responseModel.isError) {
        return TxErrorModel(isError: true, error: responseModel.error);
      }

      var accToUtxoTxId = await _waitPreviousTx(responseModel);

      if (accToUtxoTxId.isError) {
        return accToUtxoTxId;
      }
    }

    var responseTxModel = await createTransaction(
      keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: destinationAddress,
        account: account,
        changeAddress: account.getActiveAddress(isChange: true),
        amount: amount);
    if (responseTxModel.isError) {
      return TxErrorModel(isError: true, error: responseTxModel.error);
    }

    return await _waitPreviousTx(responseTxModel);
  }

  Future<TxErrorModel> createAndSendToken(
      {required AccountModel account,
        required ECPair keyPair,
      required String token,
      required String destinationAddress,
      required int amount, required List<TokensModel> tokens}) async {

    await _getUtxoList(account);

    var tokenId = await tokensRequests.getTokenID(token, tokens);

    var responseModel = await createTransaction(
      keyPair:keyPair,
        utxoList: accountUtxoList,
        destinationAddress: destinationAddress,
        account: account,
        changeAddress: account.getActiveAddress(isChange: true),
        amount: 0,
        additional: (txb, nw, newUtxo) {
            txb.addAccountToAccountOutputAt(tokenId, destinationAddress,
                destinationAddress, amount, 0);
        },
        useAllUtxo: true);
    if (responseModel.isError) {
      return TxErrorModel(isError: true, error: responseModel.error);
    }

    return await _waitPreviousTx(responseModel);
  }

  Future<TxErrorModel> createAndSendSwap(
      {required AccountModel account,
        required ECPair keyPair,
      required String tokenFrom,
      required String tokenTo,
      required int amount, required int amountTo, required List<TokensModel> tokens, double slippage = 0.03}) async
  {
    var tokenFromId = await tokensRequests.getTokenID(tokenFrom, tokens);
    var tokenToId = await tokensRequests.getTokenID(tokenTo, tokens);

    var maxPrice = amount / (amountTo) * (1 + slippage);
    var oneHundredMillions = 100000000;
    var n = maxPrice * oneHundredMillions;
    var fraction = (n % oneHundredMillions).round();
    var integer = ((n - fraction) / oneHundredMillions).round();

    await _getUtxoList(account);

    if (tokenFrom == 'DFI') {
      var addressBalanceList = await balanceRequests
          .getAddressBalanceListByAddressList(account.addressList!);
      var tokenBalance =
          balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

      if (tokenBalance < amount) {
        var responseModel = await createTransaction(
            keyPair: keyPair,
            utxoList: accountUtxoList,
            account: account,
            destinationAddress: account.addressList![0].address!,
            changeAddress: account.getActiveAddress(isChange: true),
            amount: 0,
            reservedBalance: amount - tokenBalance,
            additional: (txb, nw, newUtxo) {
              txb.addUtxosToAccountOutput(
                  tokenFromId,
                  account.addressList![0].address!,
                  amount - tokenBalance,
                  nw);
            });

        var utxoToAccTxid = await _waitPreviousTx(responseModel);
        if (utxoToAccTxid.isError) {
          return utxoToAccTxid;
        }
      }
    }

    var responseModel = await createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: account.getActiveAddress(isChange: false),
        changeAddress: account.getActiveAddress(isChange: true),
        amount: 0,
        account: account,
        additional: (txb, nw, newUtxo) {
          txb.addSwapOutput(
              tokenFromId,
              account.addressList![0].address!,
              amount,
              tokenToId,
              account.getActiveAddress(isChange: false),
              integer,
              fraction);
        },
        useAllUtxo: true);
    if (responseModel.isError) {
      return TxErrorModel(isError: true, error: responseModel.error);
    }

    return await _waitPreviousTx(responseModel);
  }

  Future<TxResponseModel> createTransaction(
      {required ECPair keyPair,
      required List<UtxoModel> utxoList,
      required String destinationAddress,
      required String changeAddress,
      required int amount,
      required AccountModel account,
      bool useAllUtxo = true,
      int reservedBalance = 0,
      Function(TransactionBuilder, NetworkType, List<UtxoModel>)?
          additional}) async {
    var sum = 0;

    List<UtxoModel> selectedUTXO = [];
    List<UtxoModel> newUTXO = [];

    if(utxoList.length == 0){
      return TxResponseModel(
          isError: true,
          error: 'Not enough balance. Wait for approval the previous tx',
          usingUTXO: [],
          newUTXO: [],
          hex: '');
    }

    if (useAllUtxo) {
      selectedUTXO = utxoList;
    } else {
      selectedUTXO = _utxoSelector(utxoList, FEE, amount);
    }

    final _txb = TransactionBuilder(
        network: networkHelper.getNetwork(SettingsHelper.settings.network!));
    _txb.setVersion(2);

    selectedUTXO.forEach((utxo) {
      _txb.addInput(utxo.mintTxId, utxo.mintIndex, null, P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: networkHelper.getNetwork(SettingsHelper.settings.network!)).data!.output);
      sum += utxo.value!;
    });

    if (sum < amount + FEE) {
        return TxResponseModel(
            isError: true,
            error: 'Not enough balance. Wait for approval the previous tx',
            usingUTXO: [],
            newUTXO: [],
            hex: '');
    }
    if (amount > 0) {
      _txb.addOutput(destinationAddress, amount);
      if (destinationAddress == account.addressList![0].address) {
        newUTXO.add(UtxoModel(
            address: destinationAddress,
            value: amount,
            mintIndex: newUTXO.length + 1));
      }
    }
    if (sum - (amount + FEE + reservedBalance) > DUST) {
      newUTXO.add(UtxoModel(
          address: changeAddress,
          value: sum - (amount + FEE + reservedBalance),
          mintIndex: newUTXO.length + 1));
      _txb.addOutput(
          changeAddress, sum - (amount + FEE + reservedBalance)); //money - fee
    }

    if (additional != null) {
      await additional(_txb,
          networkHelper.getNetwork(SettingsHelper.settings.network!), newUTXO);
    }

    selectedUTXO.asMap().forEach((index, utxo) {
      _txb.sign(
          vin: index,
          keyPair: keyPair,
          witnessValue: utxo.value);
    });


    TxResponseModel responseModel = TxResponseModel(
        hex: _txb.build().toHex(),
        usingUTXO: selectedUTXO,
        newUTXO: newUTXO,
        isError: false,
        amount: amount);
    return responseModel;
  }

  List<UtxoModel> _utxoSelector(List<UtxoModel> utxos, int fee, int amount) {
    utxos = _shuffle(utxos);
    List<UtxoModel> selectedUtxo = [];
    int sum = 0;
    int i = 0;
    do {
      selectedUtxo.add(utxos[i]);
      sum += utxos[i].value!;
      if (selectedUtxo.length < utxos.length) {
        i++;
      } else {
        break;
      }
    } while (sum <= amount + fee || sum - (amount + fee) < DUST);
    return selectedUtxo;
  }

  List<UtxoModel> _shuffle(List<UtxoModel> items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  Future<List<UtxoModel>> _getUtxoList(AccountModel account) async {
    if (accountUtxoList.isEmpty) {
      accountUtxoList =
      await transactionRequests.getUTXOs(addresses: account.addressList!);
    }

    return accountUtxoList;
  }

  void _updateUtxoList(TxResponseModel responseModel, String txid) {
      List<UtxoModel> usingUtxo = [];
      responseModel.usingUTXO.forEach((data) {
        Map<dynamic, dynamic> dataJson = data.toJson();
        usingUtxo.add(UtxoModel.fromJson(dataJson));
      });

      for(var i = 0; i < usingUtxo.length;i++){
        accountUtxoList.removeWhere((item) {
           return item.mintTxId == usingUtxo[i].mintTxId &&
              item.mintIndex == usingUtxo[i].mintIndex;
        });
      }

    responseModel.newUTXO.forEach((element) {
      accountUtxoList.add(UtxoModel(
          address: element.address!,
          mintIndex: element.mintIndex,
          mintTxId: txid,
          value: element.value));
    });
  }

  Future<TxErrorModel> _waitPreviousTx(TxResponseModel responseModel) async {
    var wait = true;
    TxErrorModel? txid;

    for (; wait;) {
      txid = await transactionRequests.sendTxHex(responseModel.hex);
      if (!txid.isError || txid.error != 'Missing inputs') {
        wait = false;
      } else {
        await new Future.delayed(new Duration(seconds: 2));
      }
    }

    if (!txid!.isError) {
      _updateUtxoList(responseModel, txid.txid!);
  }

    return txid;
  }

  int calculateBTCFee(int inputCount, int outputCount, int satPerByte){
    int txBodySize = 10;
    int txInputSize = 148;
    int txOutputSize = 34;

    return (txBodySize+inputCount*txInputSize+txOutputSize*outputCount)*satPerByte;
  }
}
