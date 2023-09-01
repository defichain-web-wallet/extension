import 'dart:convert';

import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_rate_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_lm_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_token_requests.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/graph.dart';
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
        await updateRates(
          network,
          jsonTokens: tokensTestnet["data"],
          jsonPoolPairs: poolpairsTestnet["data"],
        );
      } else {
        await updateRates(
          network,
          jsonTokens: tokensMainnet["data"],
          jsonPoolPairs: poolpairsMainnet["data"],
        );
      }
    } else {
      await updateRates(network);
    }
  }

  Future<void> updateRates(
    AbstractNetworkModel network, {
    String jsonTokens = '',
    String jsonPoolPairs = '',
  }) async {
    List<TokenModel> tokens = await _getTokens(
      network,
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
    AbstractNetworkModel network, {
    String json = '',
  }) async {
    if (json.isEmpty) {
      return await DFITokenRequests.getTokens(networkType: network.networkType);
    } else {
      var data = jsonDecode(json);

      return List<TokenModel>.generate(
        data.length,
        (index) => TokenModel.fromJSON(
          data[index],
          networkName: network.networkType.networkName,
        ),
      );
    }
  }

  double convertAmountBalance(
    AbstractNetworkModel networkModel,
    BalanceModel balanceModel, {
    String convertToken = 'USDT',
    EthereumRateModel? ethereumRateModel,
  }) {
    late double amount;
    if (networkModel is EthereumNetworkModel && ethereumRateModel != null) {
      amount = networkModel.fromSatoshi(
        balanceModel.balance,
        decimals: balanceModel.token!.tokenDecimals,
      );
      return amount *
          ethereumRateModel.assetPrice(
            balanceModel.token!.symbol,
            convertToken,
          );
    } else {
      amount = networkModel.fromSatoshi(balanceModel.balance);
      if (balanceModel.token != null) {
        return getAmountByToken(
          amount,
          balanceModel.token!,
          convertToken: convertToken,
        );
      } else {
        return getPoolPairsByToken(
          balanceModel.balance,
          balanceModel.lmPool!,
          convertToken: convertToken,
        );
      }
    }
  }

  double getTotalAmount(
    AbstractNetworkModel networkModel,
    List<BalanceModel> balances, {
    String convertToken = 'USDT',
    EthereumRateModel? ethereumRateModel,
  }) {
    if (networkModel is EthereumNetworkModel && ethereumRateModel != null) {
      return balances.map<double>((e) {
        double amount = networkModel.fromSatoshi(
          e.balance,
          decimals: e.token!.tokenDecimals,
        );
        return amount *
            ethereumRateModel!.assetPrice(
              e.token!.symbol,
              convertToken,
            );
      }).reduce((value, element) => value + element);
    } else {
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
  }

  double getAmountByToken(
    double amount,
    TokenModel token, {
    String convertToken = 'USDT',
  }) {
    LmPoolModel lmPoolModel;
    double sum = amount;

    if (token.symbol == convertToken) {
      return amount;
    }

    try {
      if (token.symbol == 'DUSD') {
        LmPoolModel foundToken = this.poolPairs!.firstWhere((element) =>
        element.tokens.first.symbol == convertToken &&
            element.tokens.last.symbol == token.symbol);
        return (1.0 / foundToken.prices.last) * amount;
      } else {
        LmPoolModel foundToken = this.poolPairs!.firstWhere((element) =>
        element.tokens.first.symbol == token.symbol &&
            element.tokens.last.symbol == convertToken);
        return (1.0 / foundToken.prices.first) * amount;
      }
    } catch (_) {
      List<String> adjacencyList = this
          .poolPairs!
          .map((e) => e.symbol)
          .where(
            (element) =>
        element != 'EUROC-DUSD' &&
            element != 'DUSD-EUROC' &&
            element != 'USDT-DUSD',
      )
          .toList();

      Graph graph = Graph(adjacencyList);

      List<String> path;
      try {
        path = graph.findPath(token.symbol, convertToken);
      } catch (_) {
        return 0.0;
      }

      path.forEach((symbol) {
        try {
          lmPoolModel =
              this.poolPairs!.firstWhere((element) => element.symbol == symbol);
          if ((path.indexOf(symbol) == path.length - 1 &&
              token.symbol != 'USDT') ||
              symbol == 'USDT-DFI' ||
              (token.symbol == 'USDT' && convertToken == 'BTC')) {
            sum = (1 / lmPoolModel.prices.last) * sum;
          } else {
            sum = (1 / lmPoolModel.prices.first) * sum;
          }
        } catch (err) {
          print(err);
        }
      });

      return sum;
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

  String getSpecificTokenName(String token) {
    switch (token) {
      case 'USD':
        return 'USDT';
      case 'EUR':
        return 'EUROC';
      default:
        return token;
    }
  }
}
