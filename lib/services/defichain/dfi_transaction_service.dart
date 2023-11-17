import 'dart:math';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/tx_response_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_transaction_requests.dart';
import 'package:defichaindart/defichaindart.dart';

import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';

class DFITransactionService {
  static const DUST = 3000;
  static const FEE = 3000;
  static const int AuthTxMin = 200000;
  var balanceRequests = BalanceRequests();
  var balancesHelper = BalancesHelper();
  List<UtxoModel> accountUtxoList = [];

  Future<TxErrorModel> createAndSendSwap({
    required String senderAddress,
    required ECPair keyPair,
    required DefichainNetworkModel network,
    required TokenModel tokenFrom,
    required TokenModel tokenTo,
    required BalanceModel balanceDFIToken,
    required int amountFrom,
    required int amountTo,
    double slippage = 0.03,
  }) async {
    TxErrorModel txErrorModel = TxErrorModel(isError: false, txLoaderList: []);

    var maxPrice = amountFrom / (amountTo) * (1 + slippage);
    var oneHundredMillions = 100000000;
    var n = maxPrice * oneHundredMillions;
    var fraction = (n % oneHundredMillions).round();
    var integer = ((n - fraction) / oneHundredMillions).round();

    await _getUtxoList(
        senderAddress, network.networkType.networkStringLowerCase);

    if (tokenFrom.symbol == 'DFI') {
      if (balanceDFIToken.balance < amountFrom) {
        var responseModel = await _utxoToAccountTransaction(
            senderAddress: senderAddress,
            keyPair: keyPair,
            network: network,
            amount: amountFrom - balanceDFIToken.balance,
            tokenId: int.parse(tokenFrom.id));

        if (responseModel.isError) {
          return TxErrorModel(isError: true, error: responseModel.error);
        }

        txErrorModel = await _prepareTx(responseModel, TxType.convertUtxo,
            network.networkType.networkStringLowerCase);
        if (txErrorModel.isError!) {
          return txErrorModel;
        }
      }
    }

    var responseModel = await _createTransaction(
        senderAddress: senderAddress,
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        network: network,
        additional: (txb, nw, newUtxo) {
          txb.addSwapOutput(
              int.parse(tokenFrom.id) < 0 ? 0 : int.parse(tokenFrom.id),
              senderAddress,
              amountFrom,
              int.parse(tokenTo.id) < 0 ? 0 : int.parse(tokenTo.id),
              senderAddress,
              integer,
              fraction);
        },
        useAllUtxo: true);

    if (txErrorModel.txLoaderList!.length > 0) {
      txErrorModel.txLoaderList!
          .add(TxLoaderModel(txHex: responseModel.hex, type: TxType.swap));
    } else {
      txErrorModel = await _prepareTx(responseModel, TxType.swap,
          network.networkType.networkStringLowerCase);
    }

    return txErrorModel;
  }

  Future<TxErrorModel> removeLiqudity({
    required String senderAddress,
    required ECPair keyPair,
    required DefichainNetworkModel network,
    required LmPoolModel pool,
    required int amount,
  }) async {
    await _getUtxoList(
        senderAddress, network.networkType.networkStringLowerCase);

    var responseModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        senderAddress: senderAddress,
        destinationAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        network: network,
        additional: (txb, nw, newUtxo) {
          txb.addRemoveLiquidityOutput(
              int.parse(pool.id), amount, senderAddress);
        });

    return await _prepareTx(responseModel, TxType.removeLiq,
        network.networkType.networkStringLowerCase);
  }

  Future<TxErrorModel> createAndSendLiqudity({
    required String senderAddress,
    required ECPair keyPair,
    required DefichainNetworkModel network,
    required BalanceModel balanceUTXO,
    required BalanceModel balanceDFIToken,
    required LmPoolModel pool,
    required List<int> amountList,
  }) async {
    await _getUtxoList(
        senderAddress, network.networkType.networkStringLowerCase);
    TxErrorModel txErrorModel = TxErrorModel(isError: false, txLoaderList: []);

    int? indexDFI;

    if (pool.tokens[0].symbol == 'DFI') {
      indexDFI = 0;
    } else if (pool.tokens[1].symbol == 'DFI') {
      indexDFI = 1;
    }

    if (indexDFI != null) {
      if (balanceDFIToken.balance + balanceUTXO.balance <
          amountList[indexDFI]) {
        return TxErrorModel(
            isError: true,
            error: 'Not enough balance. Wait for approval the previous tx');
      }

      if (balanceDFIToken.balance < amountList[indexDFI]) {
        var responseModel = await _utxoToAccountTransaction(
            senderAddress: senderAddress,
            network: network,
            keyPair: keyPair,
            amount: amountList[indexDFI] - balanceDFIToken.balance,
            tokenId: int.parse(pool.tokens[indexDFI].id));

        txErrorModel = await _prepareTx(responseModel, TxType.convertUtxo,
            network.networkType.networkStringLowerCase);
        if (txErrorModel.isError!) {
          return txErrorModel;
        }
      }
    }

    var responseModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        network: network,
        additional: (txb, nw, newUtxo) {
          txb.addAddLiquidityOutputSingleAddress(
              senderAddress,
              int.parse(pool.tokens[0].id),
              amountList[0],
              int.parse(pool.tokens[1].id),
              amountList[1],
              senderAddress);
        },
        useAllUtxo: true);

    if (txErrorModel.txLoaderList!.length > 0) {
      txErrorModel.txLoaderList!
          .add(TxLoaderModel(txHex: responseModel.hex, type: TxType.addLiq));
    } else {
      txErrorModel = await _prepareTx(responseModel, TxType.addLiq,
          network.networkType.networkStringLowerCase);
    }

    return txErrorModel;
  }

  Future<TxResponseModel> _utxoToAccountTransaction(
      {required ECPair keyPair,
      required int amount,
      required String senderAddress,
      required int tokenId,
      required DefichainNetworkModel network}) {
    return _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        network: network,
        reservedBalance: amount,
        additional: (txb, nw, newUtxo) {
          txb.addUtxosToAccountOutput(0, senderAddress, amount, nw);
        });
  }

  Future<TxErrorModel> createSendTransaction({
    required String senderAddress,
    required ECPair keyPair,
    required BalanceModel balanceUTXO,
    required BalanceModel balance,
    required String destinationAddress,
    required DefichainNetworkModel network,
    required int amount,
  }) async {
    if (balance.token!.symbol == 'DFI') {
      return _createSendUTXOTransaction(
          keyPair: keyPair,
          balance: balance,
          destinationAddress: destinationAddress,
          amount: amount,
          senderAddress: senderAddress,
          network: network);
    } else {
      return _createAndSendToken(
          keyPair: keyPair,
          token: balance.token!,
          destinationAddress: destinationAddress,
          amount: amount,
          senderAddress: senderAddress,
          network: network);
    }
  }

  Future<TxErrorModel> _createSendUTXOTransaction({
    required String senderAddress,
    required ECPair keyPair,
    required String destinationAddress,
    required DefichainNetworkModel network,
    required int amount,
    required BalanceModel balance,
  }) async {
    TxResponseModel? responseModel;
    TxErrorModel txErrorModel = TxErrorModel(isError: false, txLoaderList: []);

    await _getUtxoList(
        senderAddress, network.networkType.networkStringLowerCase);

    //Swap DFI tokens to UTXO if needed
    if (balance.balance >= DUST) {
      responseModel = await _createTransaction(
          keyPair: keyPair,
          utxoList: accountUtxoList,
          destinationAddress: destinationAddress,
          changeAddress: senderAddress,
          amount: 0,
          network: network,
          senderAddress: senderAddress,
          additional: (txb, nw, newUtxo) {
            final mintingStartsAt = txb.tx!.outs.length + 1;
            newUtxo.add(
              UtxoModel(
                address: senderAddress,
                value: balance.balance,
                mintIndex: newUtxo.length + 1,
              ),
            );
            txb.addOutput(senderAddress, balance.balance);
            txb.addAccountToUtxoOutput(
              int.parse(balance.token!.id),
              senderAddress,
              balance.balance,
              mintingStartsAt,
            );
          });
      if (responseModel.isError) {
        return TxErrorModel(isError: true, error: responseModel.error);
      }

      txErrorModel = await _prepareTx(responseModel, TxType.convertUtxo,
          network.networkType.networkStringLowerCase);

      if (txErrorModel.isError!) {
        return txErrorModel;
      }
    }

    var responseTxModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: destinationAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        network: network,
        amount: amount);
    if (responseTxModel.isError) {
      return TxErrorModel(isError: true, error: responseTxModel.error);
    }

    if (txErrorModel.txLoaderList!.length > 0) {
      txErrorModel.txLoaderList!
          .add(TxLoaderModel(txHex: responseTxModel.hex, type: TxType.send));
    } else {
      txErrorModel = await _prepareTx(responseTxModel, TxType.send,
          network.networkType.networkStringLowerCase);
    }

    return txErrorModel;
  }

  Future<TxErrorModel> _createAndSendToken({
    required String senderAddress,
    required ECPair keyPair,
    required TokenModel token,
    required DefichainNetworkModel network,
    required String destinationAddress,
    required int amount,
  }) async {
    await _getUtxoList(
        senderAddress, network.networkType.networkStringLowerCase);

    var responseModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        network: network,
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txb.addAccountToAccountOutputAt(int.parse(token.id), senderAddress,
              destinationAddress, amount, 0);
        },
        useAllUtxo: true);
    if (responseModel.isError) {
      return TxErrorModel(isError: true, error: responseModel.error);
    }

    return await _prepareTx(
        responseModel, TxType.send, network.networkType.networkStringLowerCase);
  }

  Future<TxResponseModel> _createTransaction({
    required ECPair keyPair,
    required List<UtxoModel> utxoList,
    required String destinationAddress,
    required String changeAddress,
    required int amount,
    required String senderAddress,
    required DefichainNetworkModel network,
    bool useAllUtxo = true,
    int reservedBalance = 0,
    Function(TransactionBuilder, NetworkType, List<UtxoModel>)? additional,
  }) async {
    var sum = 0;

    List<UtxoModel> selectedUTXO = [];
    List<UtxoModel> newUTXO = [];

    if (utxoList.length == 0) {
      return TxResponseModel(
          isError: true,
          error: 'Not enough balance. Wait for approval the previous tx',
          usingUTXO: [],
          newUTXO: [],
          hex: '');
    }
    var sumUtxo = 0;
    utxoList.forEach((UtxoModel utxo){sumUtxo += utxo.value!;});

    if(sumUtxo < (amount + FEE)){
      return TxResponseModel(
          isError: true,
          error: 'Not enough balance for pay fee. Wait for approval the previous tx or add more DFI',
          usingUTXO: [],
          newUTXO: [],
          hex: '');
    }

    if (useAllUtxo) {
      selectedUTXO = utxoList;
    } else {
      selectedUTXO = _utxoSelector(utxoList, FEE, amount);
    }

    final _txb = TransactionBuilder(network: network.getNetworkType());
    _txb.setVersion(2);

    selectedUTXO.forEach((utxo) {
      _txb.addInput(
          utxo.mintTxId,
          utxo.mintIndex,
          null,
          P2WPKH(
                  data: PaymentData(pubkey: keyPair.publicKey),
                  network: network.getNetworkType())
              .data!
              .output);
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
      if (destinationAddress == senderAddress) {
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
      await additional(_txb, network.getNetworkType(), newUTXO);
    }

    selectedUTXO.asMap().forEach((index, utxo) {
      _txb.sign(vin: index, keyPair: keyPair, witnessValue: utxo.value);
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

  Future<List<UtxoModel>> _getUtxoList(
      String address, String networkString) async {
    if (accountUtxoList.isEmpty) {
      accountUtxoList = await DFITransactionRequests.getUTXOs(
          address: address, networkString: networkString);
    }

    return accountUtxoList;
  }

  void _updateUtxoList(TxResponseModel responseModel, String txid) {
    List<UtxoModel> usingUtxo = [];
    responseModel.usingUTXO.forEach((data) {
      Map<dynamic, dynamic> dataJson = data.toJson();
      usingUtxo.add(UtxoModel.fromJson(dataJson));
    });

    for (var i = 0; i < usingUtxo.length; i++) {
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

  Future<TxErrorModel> _prepareTx(
    TxResponseModel responseModel,
    TxType type,
    String networkString,
  ) async {
    TxErrorModel? txid = await DFITransactionRequests.sendTxHex(
        txHex: responseModel.hex, networkString: networkString);
    if (!txid.isError!) {
      _updateUtxoList(responseModel, txid.txLoaderList![0].txId!);
      txid.txLoaderList![0].type = type;
    }

    return txid;
  }
}
