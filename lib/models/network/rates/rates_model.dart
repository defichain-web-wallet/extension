import 'dart:convert';

import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_lm_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_token_requests.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RatesModel {
  List<TokenModel>? tokens;
  List<LmPoolModel>? poolPairs;

  RatesModel({
    this.tokens,
    this.poolPairs,
  });

  loadTokens(AbstractNetworkModel network) async {
    var boxrates = await Hive.openBox('rates');
    var tokensMainnet = await boxrates.get('tokensMainnet');
    var tokensTestnet = await boxrates.get('tokensTestnet');
    var poolpairsMainnet = await boxrates.get('poolpairsMainnet');
    var poolpairsTestnet = await boxrates.get('poolpairsTestnet');
    await boxrates.close();

    if (tokensMainnet != null && poolpairsMainnet != null) {
      if (network.networkType.isTestnet) {
        updateRates(
          network,
          jsonTokens: tokensTestnet["data"],
          jsonPoolPairs: poolpairsTestnet["data"],
        );
      } else {
        updateRates(
          network,
          jsonTokens: tokensMainnet["data"],
          jsonPoolPairs: poolpairsMainnet["data"],
        );
      }
    } else {
      updateRates(network);
    }
  }

  Future<void> updateRates(
    AbstractNetworkModel network, {
    String jsonTokens = '',
    String jsonPoolPairs = '',
  }) async {
    List<TokenModel> tokens = await _getTokens(
      network.networkType,
      json: jsonTokens,
    );
    await _setTokensAndPoolPairs(
      network.networkType,
      tokens,
      json: jsonPoolPairs,
    );
  }

  Future<void> _setTokensAndPoolPairs(
    NetworkTypeModel networkType,
    List<TokenModel> tokens, {
    String json = '',
  }) async {
    if (json.isEmpty) {
      this.poolPairs = await DFILmRequests.getLmPools(
        networkType: networkType,
        tokens: tokens,
      );
    } else {
      var data = jsonDecode(json);

      this.poolPairs = List<LmPoolModel>.generate(
        data.length,
        (index) => LmPoolModel.fromJSON(
          data[index],
          tokens: tokens,
          networkName: networkType.networkName,
        ),
      );
    }
    this.tokens = tokens;
  }

  Future<List<TokenModel>> _getTokens(
    NetworkTypeModel networkType, {
    String json = '',
  }) async {
    if (json.isEmpty) {
      return await DFITokenRequests.getTokens(networkType: networkType);
    } else {
      var data = jsonDecode(json);

      return List<TokenModel>.generate(
        data.length,
        (index) => TokenModel.fromJSON(
          data[index],
          networkName: networkType.networkName,
        ),
      );
    }
  }

  double convertAmountBalance(
    AbstractNetworkModel networkModel,
    BalanceModel balanceModel, {
    String convertToken = 'USDT',
  }) {
    double amount = networkModel.fromSatoshi(balanceModel.balance);
    if (balanceModel.token != null) {
      return getAmountByToken(amount, balanceModel.token!);
    } else {
      return getPoolPairsByToken(balanceModel.balance, balanceModel.lmPool!);
    }
  }

  double getTotalAmount(
    AbstractNetworkModel networkModel,
    List<BalanceModel> balances, {
    String convertToken = 'USDT',
  }) {
    return balances.map<double>((e) {
      if (e.token != null) {
        return getAmountByToken(
          networkModel.fromSatoshi(e.balance),
          e.token!,
          convertToken: convertToken,
        );
      } else {
        return getPoolPairsByToken(
          e.balance,
          e.lmPool!,
          convertToken: convertToken,
        );
      }
    }).reduce((value, element) => value + element);
  }

  double getAmountByToken(
    double amount,
    TokenModel token, {
    String convertToken = 'USDT',
  }) {
    String symbol = '$convertToken-DFI';
    String testnetSymbol = 'DFI-$convertToken';

    try {
      LmPoolModel assetPair = this.poolPairs!.firstWhere((element) =>
          element.symbol == symbol || element.symbol == testnetSymbol);
      if (token.symbol == 'DFI') {
        return assetPair.reserveADivReserveB * amount;
      }

      // TODO: convert to DUSD doesn't work correctly. Need to check later
      LmPoolModel targetPair = this.poolPairs!.firstWhere((item) {
        return item.tokens.first.symbol == token.symbol &&
            (item.tokens.last.symbol == 'DFI' ||
                item.tokens.last.symbol == 'DUSD');
      });

      double dfiByConvertToken = assetPair.reserveADivReserveB;
      double dfiByToken = targetPair.reserveBDivReserveA;

      double result;
      if (targetPair.tokens.last.symbol == 'DUSD') {
        result = (dfiByConvertToken * amount);
        return result;
      } else {
        double result = (dfiByToken * amount) * dfiByConvertToken;
        return result;
      }
    } catch (err) {
      return 0.00;
    }
  }

  double getPoolPairsByToken(
    int satoshi,
    LmPoolModel lmPoolModel, {
    String convertToken = 'USDT',
  }) {
    try {
      LmPoolModel assetPair = this
          .poolPairs!
          .firstWhere((element) => element.symbol == lmPoolModel.symbol);
      int totalLiquidity = convertToSatoshi(assetPair.totalLiquidityRaw!);
      double baseBalance =
          satoshi * (1 / totalLiquidity) * assetPair.reserves!.first;
      double quoteBalance =
          satoshi * (1 / totalLiquidity) * assetPair.reserves!.last;
      double baseBalanceByAsset;
      double quoteBalanceByAsset;

      TokenModel baseAsset = assetPair.tokens.first;
      TokenModel quoteAsset = assetPair.tokens.last;

      baseBalanceByAsset = getAmountByToken(
        baseBalance,
        baseAsset,
        convertToken: convertToken,
      );
      quoteBalanceByAsset = getAmountByToken(
        quoteBalance,
        quoteAsset,
        convertToken: convertToken,
      );

      return baseBalanceByAsset + quoteBalanceByAsset;
    } catch (_) {
      return 0.00;
    }
  }
}
