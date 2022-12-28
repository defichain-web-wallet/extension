import 'dart:math';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
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
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:defichaindart/defichaindart.dart';

import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';

import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;

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

    var sumAmount = 0;
    late TxErrorModel response;

    for (var element in account.addressList!) {
      if (sumAmount < amount) {
        var balances = await balanceRequests.getBalanceListByAddress(
            element.address!, true, SettingsHelper.settings.network!);

        for (var balance in balances) {
          if (balance.token == token.symbol!) {
            var authTxidModel = await _createAuthTx(
                keyPair: keyPair,
                utxoList:
                accountUtxoList,
                destinationAddress: element,
                account: account);
            if (authTxidModel.isError) {
              return authTxidModel;
            }

            var sendedAmount = 0;
            if (balance.balance! >= amount - sumAmount) {
              sendedAmount = amount - sumAmount;
              sumAmount += amount - sumAmount;
            } else {
              sendedAmount = balance.balance!;
              sumAmount += balance.balance!;
            }
             var responseModel = await createTransaction(
               keyPair: keyPair,
                utxoList: [authTxidModel.utxo!],
                isAuth: false,
                account: account,
                destinationAddress: element.address!,
                changeAddress: element.address!,
                amount: 0,
                additional: (txb, nw, newUtxo) {
                    txb.addRemoveLiquidityOutput(
                        token.id!, sendedAmount, element.address!);
                },
                useAllUtxo: true);
            response = await _waitPreviousTx(responseModel);
          }
        }
      }
    }

    return response;
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

  int calculateBTCFee(int inputCount, int outputCount, int satPerByte){
    int txBodySize = 10;
    int txInputSize = 148;
    int txOutputSize = 34;

    return (txBodySize+inputCount*txInputSize+txOutputSize*outputCount)*satPerByte;
  }

  Future<TxErrorModel> createAndSendLiqudity(
      {required AccountModel account,
        required ECPair keyPair,
      required String tokenA,
      required String tokenB,
      required int amountA,
      required int amountB,
      required List<TokensModel> tokens}) async {

    int? amountDFI;

    await _getUtxoList(account);

    //TODO: refactoring crutch
    if (tokenA == 'DFI') {
      amountDFI = amountA;
    } else if (tokenB == 'DFI') {
      amountDFI = amountB;
    }
    var addressBalanceList = await balanceRequests
        .getAddressBalanceListByAddressList(account.addressList!);


    if(amountDFI != null){
      var addressDFI = tokenA == 'DFI' ?
      account.addressList![0] : account.addressList![0];
      var tokenDFIbalanceAll =
      balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

      var coinDFIbalanceAll =
      balancesHelper.getBalanceByTokenName(addressBalanceList, '\$DFI');

      if (tokenDFIbalanceAll + coinDFIbalanceAll < amountDFI) {
        return TxErrorModel(isError: true, error: 'Not enough balance. Wait for approval the previous tx');
      }

      var tokenDFIId = await tokensRequests.getTokenID('DFI', tokens);

      var balanceListForDFI = await balanceRequests
          .getAddressBalanceListByAddressList([addressDFI]);
      var tokenDFIBalanceOnAddress =
      balancesHelper.getBalanceByTokenName(balanceListForDFI, 'DFI');

      if (tokenDFIBalanceOnAddress < tokenDFIbalanceAll) {
        var sendDFITokenTxid = await createAndSendToken(
            keyPair: keyPair,
            account: account,
            token: 'DFI',
            destinationAddress: addressDFI.address!,
            amount: tokenDFIbalanceAll, tokens: tokens);
        if (sendDFITokenTxid.isError) {
          return sendDFITokenTxid;
        }
      }

      if (tokenDFIbalanceAll < amountDFI) {
        var responseModel = await createTransaction(
          keyPair: keyPair,
            utxoList: accountUtxoList,
            isAuth: false,
            account: account,
            destinationAddress: addressDFI.address!,
            changeAddress: account.getActiveAddress(isChange: true),
            amount: 0,
            reservedBalance: amountDFI - tokenDFIbalanceAll,
            additional: (txb, nw, newUtxo) {
              txb.addUtxosToAccountOutput(
                  tokenDFIId,
                  addressDFI.address!,
                  amountDFI! - tokenDFIbalanceAll,
                  nw);
            },
            useAllUtxo: true);

        var utxoToAccTxid = await _waitPreviousTx(responseModel);
        if (utxoToAccTxid.isError) {
          return utxoToAccTxid;
        }
      }
    }

    List<UtxoModel> selectedUtxoList = [];

    var tokenAbalanceAll =
        balancesHelper.getBalanceByTokenName(addressBalanceList, tokenA);
    var tokenBbalanceAll =
        balancesHelper.getBalanceByTokenName(addressBalanceList, tokenB);

    var balanceListForTokenA = await balanceRequests
        .getAddressBalanceListByAddressList([account.addressList![0]]);
    var balanceListForTokenB = await balanceRequests
        .getAddressBalanceListByAddressList([account.addressList![0]]);

    var tokenABalanceOnAddress =
        balancesHelper.getBalanceByTokenName(balanceListForTokenA, tokenA);
    var tokenBBalanceOnAddress =
        balancesHelper.getBalanceByTokenName(balanceListForTokenB, tokenB);


  if(tokenA != 'DFI'){
    if(tokenAbalanceAll < amountA){
      return TxErrorModel(isError: true, error: 'Not enough balance. Wait for approval the previous tx');
    }
    if (tokenABalanceOnAddress < amountA) {
      var sendTokenATxid = await createAndSendToken(
          keyPair: keyPair,
          account: account,
          token: tokenA,
          destinationAddress: account.addressList![0].address!,
          amount: amountA,tokens: tokens);
      if (sendTokenATxid.isError) {
        return sendTokenATxid;
      }
    }
  }
    if(tokenB != 'DFI'){
      if(tokenBbalanceAll < amountB){
        return TxErrorModel(isError: true, error: 'Not enough balance. Wait for approval the previous tx');
      }
      if (tokenBBalanceOnAddress < amountB) {
        var sendTokenBTxid = await createAndSendToken(
            keyPair: keyPair,
            account: account,
            token: tokenB,
            destinationAddress: account.addressList![0].address!,
            amount: amountB, tokens: tokens);
        if (sendTokenBTxid.isError) {
          return sendTokenBTxid;
        }
      }
    }

    var authResponseA = await _createAuthTx(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: account.addressList![0],
        account: account);
    if (authResponseA.isError) {
      return authResponseA;
    }

    selectedUtxoList.add(authResponseA.utxo!);

    var authResponseB = await _createAuthTx(
        keyPair: keyPair,
        utxoList: accountUtxoList
            .where((utxo) =>
        !(utxo.mintTxId == authResponseA.utxo!.mintTxId &&
                utxo.mintIndex == authResponseA.utxo!.mintIndex))
            .toList(),
        destinationAddress: account.addressList![0],
        account: account);
    if (authResponseB.isError) {
      return authResponseB;
    }

    selectedUtxoList.add(authResponseB.utxo!);

    var tokenAId = await tokensRequests.getTokenID(tokenA, tokens);
    var tokenBId = await tokensRequests.getTokenID(tokenB, tokens);

    var responseModel = await createTransaction(
      keyPair: keyPair,
        utxoList: selectedUtxoList,
        isAuth: false,
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
    List<TxAuthModel> txAuthList = [];
    TxResponseModel? responseModel;

    await _getUtxoList(account);

    for (var element in account.addressList!) {
      var balances = await balanceRequests.getBalanceListByAddress(
          element.address!, false, SettingsHelper.settings.network!);
      for (var balance in balances) {
        if (balance.token == 'DFI' && balance.balance! > 0) {
          if (balance.balance! >= DUST) {
            var authTxidModel = await _createAuthTx(
                keyPair: keyPair,
                utxoList: _utxoSelectorForSendToken(
                    accountUtxoList, txAuthList),
                destinationAddress: element,
                account: account);
            if (authTxidModel.isError) {
              return authTxidModel;
            }

            responseModel = await createTransaction(
              keyPair: keyPair,
                utxoList: [authTxidModel.utxo!],
                isAuth: false,
                destinationAddress: destinationAddress,
                changeAddress: account.getActiveAddress(isChange: true),
                amount: 0,
                account: account,
                additional: (txb, nw, newUtxo) {
                  final mintingStartsAt = txb.tx!.ins.length + 1;
                  newUtxo.add(UtxoModel(
                      address: element.address!,
                      value: balance.balance!,
                      mintIndex: newUtxo.length + 1));
                  txb.addOutput(element.address!, balance.balance!);
                  txb.addAccountToUtxoOutput(tokenId, element.address!,
                      balance.balance!, mintingStartsAt);
                },
                useAllUtxo: true);
            if (responseModel.isError) {
              return TxErrorModel(isError: true, error: responseModel.error);
            }

            var utxoToAccTxId = await _waitPreviousTx(responseModel);

            if (utxoToAccTxId.isError) {
              return utxoToAccTxId;
            }

            txAuthList.add(TxAuthModel(
                address: element,
                txid: authTxidModel.txid,
                mintIndex: 1,
                value: balance.balance!));
          }
        }
      }
    }

    var responseTxModel = await createTransaction(
      keyPair: keyPair,
        utxoList: accountUtxoList,
        isAuth: false,
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
    print(tokens.runtimeType);
    await _getUtxoList(account);

    var tokenId = await tokensRequests.getTokenID(token, tokens);

    List<TxAuthModel> txAuthList = [];
    List<UtxoModel> selectedUtxoList = [];
    var sumAmount = 0;

    for (var element in account.addressList!) {
      if (sumAmount < amount) {
        var balances = await balanceRequests.getBalanceListByAddress(
            element.address!, true, SettingsHelper.settings.network!);

        for (var balance in balances) {
          if (balance.token == token) {
            var authTxidModel = await _createAuthTx(
                keyPair: keyPair,
                utxoList:
                    _utxoSelectorForSendToken(accountUtxoList, txAuthList),
                destinationAddress: element,
                account: account);
            if (authTxidModel.isError) {
              return authTxidModel;
            }


            var sendedAmount = 0;
            if (balance.balance! >= amount - sumAmount) {
              sendedAmount = amount - sumAmount;
              sumAmount += amount - sumAmount;
            } else {
              sendedAmount = balance.balance!;
              sumAmount += balance.balance!;
            }
            selectedUtxoList.add(authTxidModel.utxo!);
            txAuthList.add(TxAuthModel(
                address: element,
                txid: authTxidModel.txid,
                mintIndex: 1,
                value: sendedAmount));
          }
        }
      }
    }

    var responseModel = await createTransaction(
      keyPair:keyPair,
        utxoList: selectedUtxoList,
        isAuth: false,
        destinationAddress: destinationAddress,
        account: account,
        changeAddress: account.getActiveAddress(isChange: true),
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txAuthList.forEach((txAuth) {
            txb.addAccountToAccountOutputAt(tokenId, txAuth.address!.address!,
                destinationAddress, txAuth.value!, 0);
          });
        },
        useAllUtxo: true);
    if (responseModel.isError) {
      return TxErrorModel(isError: true, error: responseModel.error);
    }

    return await _waitPreviousTx(responseModel);
  }

//TODO: Need refactoring this function  #fastest_programing
  Future<TxErrorModel> createAndSendSwap(
      {required AccountModel account,
        required ECPair keyPair,
      required String tokenFrom,
      required String tokenTo,
      required int amount, required int amountTo, required List<TokensModel> tokens, double slippage = 0.03}) async {
    var tokenFromId = await tokensRequests.getTokenID(tokenFrom, tokens);
    var tokenToId = await tokensRequests.getTokenID(tokenTo, tokens);

    var maxPrice = amount / (amountTo) * (1 + slippage);
    var oneHundredMillions = 100000000;
    var n = maxPrice * oneHundredMillions;
    var fraction = (n % oneHundredMillions).round();
    var integer = ((n - fraction) / oneHundredMillions).round();

    await _getUtxoList(account);

    List<TxAuthModel> txAuthList = [];
    List<UtxoModel> selectedUtxoList = [];
    if (tokenFrom == 'DFI') {
      var addressBalanceList = await balanceRequests
          .getAddressBalanceListByAddressList(account.addressList!);
      var tokenBalance =
          balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

      if (tokenBalance >= amount) {
        var sumAmount = 0;
        for (var element in addressBalanceList) {
          if (sumAmount < amount) {
            for (var balance in element.balanceList!) {
              if (balance.token == 'DFI') {
                var utxoList =
                    _utxoSelectorForSendToken(accountUtxoList, txAuthList);

                var authTxidModel = await _createAuthTx(
                    keyPair: keyPair,
                    utxoList: utxoList,
                    destinationAddress: element.addressModel!,
                    account: account);
                if (authTxidModel.isError) {
                  return authTxidModel;
                }

                var sendedAmount = 0;
                if (balance.balance! >= amount - sumAmount) {
                  sendedAmount = amount - sumAmount;
                  sumAmount += amount - sumAmount;
                } else {
                  sendedAmount = balance.balance!;
                  sumAmount += balance.balance!;
                }

                selectedUtxoList.add(authTxidModel.utxo!);
                txAuthList.add(TxAuthModel(
                    address: element.addressModel!,
                    txid: authTxidModel.txid,
                    mintIndex: 1,
                    value: sendedAmount));
              }
            }
          }
        }
      } else {
        var needAmount = amount - tokenBalance;
        var selectedUtxo = _utxoSelector(accountUtxoList, FEE, needAmount);
        var activeAddress = account.getActiveAddress(isChange: false);
        var responseModel = await createTransaction(
          keyPair: keyPair,
            utxoList: selectedUtxo,
            isAuth: false,
            account: account,
            destinationAddress: account.getActiveAddress(isChange: false),
            changeAddress: account.getActiveAddress(isChange: true),
            amount: 0,
            reservedBalance: needAmount,
            additional: (txb, nw, newUtxo) {
              txb.addUtxosToAccountOutput(tokenFromId,
                  activeAddress, needAmount, nw);
            },
            useAllUtxo: true);
        if (responseModel.isError) {
          return TxErrorModel(isError: true, error: responseModel.error);
        }

        var utxoToAccTxId = await _waitPreviousTx(responseModel);

        if (utxoToAccTxId.isError) {
          return utxoToAccTxId;
        }

        await _waitConfirmTx(utxoToAccTxId.txid!);
        await _getUtxoList(account);

        addressBalanceList = balancesHelper.updateBalance(addressBalanceList, activeAddress, 'DFI', needAmount);

        var sumAmount = 0;
        for (var element in addressBalanceList) {
          if (sumAmount < amount) {
            for (var balance in element.balanceList!) {
              if (balance.token == 'DFI') {
                var utxoList =
                    _utxoSelectorForSendToken(accountUtxoList, txAuthList);

                var authTxidModel = await _createAuthTx(
                    keyPair: keyPair,
                    utxoList: utxoList,
                    destinationAddress: element.addressModel!,
                    account: account);

                if (authTxidModel.isError) {
                  return authTxidModel;
                }

                var sendedAmount = 0;
                if (balance.balance! >= amount - sumAmount) {
                  sendedAmount = amount - sumAmount;
                  sumAmount += amount - sumAmount;
                } else {
                  sendedAmount = balance.balance!;
                  sumAmount += balance.balance!;
                }

                selectedUtxoList.add(authTxidModel.utxo!);
                txAuthList.add(TxAuthModel(
                    address: element.addressModel!,
                    txid: authTxidModel.txid,
                    mintIndex: 1,
                    value: sendedAmount));
              }
            }
          }
        }
      }
    } else {
      var sumAmount = 0;
      for (var element in account.addressList!) {
        if (sumAmount < amount) {
          var balances = await balanceRequests.getBalanceListByAddress(
              element.address!, true, SettingsHelper.settings.network!);
          for (var balance in balances) {
            if (balance.token == tokenFrom) {
              var utxoList =
                  _utxoSelectorForSendToken(accountUtxoList, txAuthList);

              var authTxidModel = await _createAuthTx(
                keyPair: keyPair,
                  utxoList: utxoList,
                  destinationAddress: element,
                  account: account);

              if (authTxidModel.isError) {
                return authTxidModel;
              }

              var sendedAmount = 0;
              if (balance.balance! >= amount - sumAmount) {
                sendedAmount = amount - sumAmount;
                sumAmount += amount - sumAmount;
              } else {
                sendedAmount = balance.balance!;
                sumAmount += balance.balance!;
              }

              selectedUtxoList.add(authTxidModel.utxo!);
              txAuthList.add(TxAuthModel(
                  address: element,
                  txid: authTxidModel.txid,
                  mintIndex: 1,
                  value: sendedAmount));
            }
          }
        }
      }
    }

     late TxResponseModel responseModel;
     late TxErrorModel response;

    for(var i = 0; i<txAuthList.length; i++) {
       responseModel = await createTransaction(
         keyPair: keyPair,
          utxoList: [selectedUtxoList[i]],
          isAuth: false,
          destinationAddress: account.getActiveAddress(isChange: false),
          changeAddress: account.getActiveAddress(isChange: true),
          amount: 0,
          account: account,
          additional: (txb, nw, newUtxo) {
            txb.addSwapOutput(
                tokenFromId,
                txAuthList[i].address!.address!,
                txAuthList[i].value!,
                tokenToId,
                account.getActiveAddress(isChange: false),
                integer,
                fraction);
          },
          useAllUtxo: true);
       if (responseModel.isError) {
         return TxErrorModel(isError: true, error: responseModel.error);
       }
       response = await _waitPreviousTx(responseModel);
    }


    return response;
  }

  Future<TxResponseModel> createTransaction(
      {required ECPair keyPair,
      required List<UtxoModel> utxoList,
      required String destinationAddress,
      required String changeAddress,
      required int amount,
      required bool isAuth,
      required AccountModel account,
      bool useAllUtxo = false,
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
      print('input: ${utxo.value!}');
      _txb.addInput(utxo.mintTxId, utxo.mintIndex, null, P2WPKH(data: PaymentData(pubkey: keyPair.publicKey), network: networkHelper.getNetwork(SettingsHelper.settings.network!)).data!.output);
      sum += utxo.value!;
    });

    if (sum < amount + FEE) {
      if (isAuth) {
        if (sum > AuthTxMin / 2) {
          amount = sum - FEE;
        } else {
          return TxResponseModel(
              isError: true,
              error: 'Not enough balance. Wait for approval the previous tx',
              usingUTXO: [],
              newUTXO: [],
              hex: '');
        }
      } else {
        return TxResponseModel(
            isError: true,
            error: 'Not enough balance. Wait for approval the previous tx',
            usingUTXO: [],
            newUTXO: [],
            hex: '');
      }
    }
    if (amount > 0) {
      account.addressList!.forEach((address) {
        if (destinationAddress == address.address) {
          newUTXO.add(UtxoModel(
              address: destinationAddress,
              value: amount,
              mintIndex: newUTXO.length + 1));
        }
      });

      print('output1: $amount');
      _txb.addOutput(destinationAddress, amount);
    }
    if (sum - (amount + FEE + reservedBalance) > DUST) {
      newUTXO.add(UtxoModel(
          address: changeAddress,
          value: sum - (amount + FEE + reservedBalance),
          mintIndex: newUTXO.length + 1));
      _txb.addOutput(
          changeAddress, sum - (amount + FEE + reservedBalance)); //money - fee
      print('output2: ${sum - (amount + FEE + reservedBalance)}');
    }

    if (additional != null) {
      await additional(_txb,
          networkHelper.getNetwork(SettingsHelper.settings.network!), newUTXO);
    }

    selectedUTXO.asMap().forEach((index, utxo) {
      final _p2wpkh = P2WPKH(
              data: PaymentData(pubkey: keyPair.publicKey),
              network:
                  networkHelper.getNetwork(SettingsHelper.settings.network!))
          .data;
      final _redeemScript = _p2wpkh!.output;
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

  List<UtxoModel> _utxoSelectorForSendToken(
      List<UtxoModel> utxos, List<TxAuthModel> txAuthList) {
    List<UtxoModel> selectedUtxo = [];
    utxos.forEach((utxo) {
      bool add = true;
      txAuthList.forEach((txAuth) {
        if (utxo.mintTxId! == txAuth.txid) {
          add = false;
        }
      });
      if (add) {
        selectedUtxo.add(utxo);
      }
    });
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
    for(var i =0; i< responseModel.usingUTXO.length;i++){
      accountUtxoList.removeWhere((item) {
        return item.mintTxId == responseModel.usingUTXO[i].mintTxId &&
            item.mintIndex == responseModel.usingUTXO[i].mintIndex;
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

  Future<TxErrorModel> _createAuthTx({
    required List<UtxoModel> utxoList,
    required ECPair keyPair,
    required AddressModel destinationAddress,
    required AccountModel account,
  }) async {
    var authResponse = await createTransaction(
      keyPair: keyPair,
        utxoList: utxoList,
        isAuth: true,
        destinationAddress: destinationAddress.address!,
        changeAddress: account.getActiveAddress(isChange: true),
        amount: AuthTxMin,
        account: account,
        additional: (txb, nw, newUtxo) {
          txb.addAuthOutput(outputIndex: 0);
        });

    var utxoToAccTxid = await _waitPreviousTx(authResponse);

    if (utxoToAccTxid.isError) {
      return utxoToAccTxid;
    }

    utxoToAccTxid.utxo = UtxoModel(
        address: destinationAddress.address!,
        mintIndex: 1,
        mintTxId: utxoToAccTxid.txid,
        value: authResponse.amount);
    return utxoToAccTxid;
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
  Future<bool> _waitConfirmTx(String txid) async {
    var wait = true;
    bool txPresent = false;

    for (; wait;) {
      try {
        txPresent = await historyRequests.getTxPresent(
            txid, SettingsHelper.settings.network!);
      } catch (err) {
        txPresent = false;
      }
      if (txPresent) {
        wait = false;
      } else {
        await new Future.delayed(new Duration(seconds: 2));
      }
    }

    return txPresent;
  }
}
