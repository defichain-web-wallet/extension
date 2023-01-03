import 'dart:math';
import 'dart:ui';

import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token_model.dart';

class TokensHelper {
  static const String DefiAccountSymbol = 'DFI';
  static const String DefiTokenSymbol = '\$DFI';
  final _random = Random();

  String getImageNameByTokenName(tokenName) {
    switch (tokenName) {
      case 'DFI':
        {
          return 'assets/tokens/defi.svg';
        }
      case 'ETH':
        {
          return 'assets/tokens/ethereum.svg';
        }
      case 'BTC':
        {
          return 'assets/tokens/bitcoin.svg';
        }
      case 'LTC':
        {
          return 'assets/tokens/litecoin.svg';
        }
      case 'DODGE':
        {
          return 'assets/tokens/dogecoin.svg';
        }
      case 'USDT':
        {
          return 'assets/tokens/usdt.svg';
        }
      case 'BCH':
        {
          return 'assets/tokens/bitcoin-cash.svg';
        }
      case 'DOGE':
        {
          return 'assets/tokens/dogecoin.svg';
        }
      case 'AAPL':
        {
          return 'assets/tokens/aapl.svg';
        }
      case 'ARKK':
        {
          return 'assets/tokens/arkk.svg';
        }
      case 'BABA':
        {
          return 'assets/tokens/baba.svg';
        }
      case 'DUSD':
        {
          return 'assets/tokens/dusd.svg';
        }
      case 'GLD':
        {
          return 'assets/tokens/gld.svg';
        }
      case 'GME':
        {
          return 'assets/tokens/gme.svg';
        }
      case 'GOOGL':
        {
          return 'assets/tokens/googl.svg';
        }
      case 'PLTR':
        {
          return 'assets/tokens/pltr.svg';
        }
      case 'PUBC':
        {
          return 'assets/tokens/pubc.svg';
        }
      case 'QQQ':
        {
          return 'assets/tokens/qqq.svg';
        }
      case 'SLV':
        {
          return 'assets/tokens/slv.svg';
        }
      case 'SPY':
        {
          return 'assets/tokens/spy.svg';
        }
      case 'TLT':
        {
          return 'assets/tokens/tlt.svg';
        }
      case 'TSLA':
        {
          return 'assets/tokens/tsla.svg';
        }
      case 'URTH':
        {
          return 'assets/tokens/urth.svg';
        }
      case 'USDC':
        {
          return 'assets/tokens/usdc.svg';
        }
      case 'VNQ':
        {
          return 'assets/tokens/vnq.svg';
        }
      case 'AMZN':
        {
          return 'assets/tokens/amzn.svg';
        }
      case 'COIN':
        {
          return 'assets/tokens/coinbase.svg';
        }
      case 'EEM':
        {
          return 'assets/tokens/eem.svg';
        }
      case 'FB':
        {
          return 'assets/tokens/fb.svg';
        }
      case 'MSFT':
        {
          return 'assets/tokens/msft.svg';
        }
      case 'NFLX':
        {
          return 'assets/tokens/nflx.svg';
        }
      case 'NVDA':
        {
          return 'assets/tokens/nvda.svg';
        }
      case 'PDBC':
        {
          return 'assets/tokens/pdbc.svg';
        }
      case 'VOO':
        {
          return 'assets/tokens/voo.svg';
        }

      default:
        {
          return 'assets/tokens/defi.svg';
        }
    }
  }

  Color getColorByTokenName(tokenName) {
    switch (tokenName) {
      case 'DFI':
        {
          return Color(0xffFF00A3);
        }
      case 'ETH':
        {
          return Color(0xff627EEA);
        }
      case 'BTC':
        {
          return Color(0xffF7931A);
        }
      case 'LTC':
        {
          return Color(0xff345D9D);
        }
      case 'DODGE':
        {
          return Color(0xffC2A633);
        }
      case 'DOGE':
        {
          return Color(0xff8E24AA);
        }
      case 'GOOGL':
        {
          return Color(0xff0288D1);
        }
      case 'TSLA':
        {
          return Color(0xffE92128);
        }
      case 'AAPL':
        {
          return Color(0xffD1A128);
        }
      case 'USDT':
        {
          return Color(0xff50AF95);
        }
      case 'BCH':
        {
          return Color(0xff8DC351);
        }
      case 'TWTR':
        {
          return Color(0xff03A9F4);
        }
      case 'FB':
        {
          return Color(0xff1E88E5);
        }
      case 'MSFT':
        {
          return Color(0xff009688);
        }
      case 'asd6f54':
        {
          return Color(0xffCDDC39);
        }
      case 'MOCK':
        {
          return Color(0xff8D6E63);
        }
      case 'DUSD':
        {
          return Color(0xffFF5722);
        }
      case 'AhmedTok':
        {
          return Color(0xffF44336);
        }
      case 'BABA':
        {
          return Color(0xffF06292);
        }
      case 'GME':
        {
          return Color(0xffBA68C8);
        }
      case 'PLTR':
        {
          return Color(0xff9575CD);
        }
      case 'ARKK':
        {
          return Color(0xff7986CB);
        }
      case 'SPY':
        {
          return Color(0xff64B5F6);
        }
      case 'QQQ':
        {
          return Color(0xff4FC3F7);
        }
      case 'GLD':
        {
          return Color(0xff4DD0E1);
        }
      case 'SLV':
        {
          return Color(0xff4DB6AC);
        }
      case 'PDBC':
        {
          return Color(0xff81C784);
        }
      case 'VNQ':
        {
          return Color(0xffAED581);
        }
      case 'URTH':
        {
          return Color(0xffDCE775);
        }
      case 'TLT':
        {
          return Color(0xffFF7043);
        }
      case 'BURN':
        {
          return Color(0xffFFB74D);
        }
      case 'NVDA':
        {
          return Color(0xff8DCD51);
        }
      case 'COIN':
        {
          return Color(0xffBA68C8);
        }
      case 'EEM':
        {
          return Color(0xff345D9D);
        }
      case 'VOO':
        {
          return Color(0xff81C784);
        }
      case 'AMZN':
        {
          return Color(0xff81C784);
        }

      default:
        {
          if (tokenName.contains('-')) {
            String baseToken = tokenName.split('-')[0];
            return getColorByTokenName(baseToken).withOpacity(0.3);
          } else {
            return Color.fromARGB(_random.nextInt(256), _random.nextInt(128),
                _random.nextInt(256), _random.nextInt(256));
          }
        }
    }
  }

  bool isDfiToken(String token) {
    if (token == DefiAccountSymbol || token == DefiTokenSymbol) return true;
    return false;
  }

  List<String> getTokens(List<TokensModel> tokens) {
    List<String> tokensForDEX = [];
    tokens.forEach((element) {
      var token = element.symbol!.split('-');
      if (token.length > 1) {
        tokensForDEX.addAll(token);
      }
    });
    return tokensForDEX.toSet().toList();
  }

  String getTokenFormat(token) {
    try {
      var tokensPair = token.split('-');
      if (tokensPair.length > 1) {
        return '${getTokenWithPrefix(tokensPair[0])}-${getTokenWithPrefix(tokensPair[1])}';
      } else {
        return getTokenWithPrefix(token);
      }
    } catch (err) {
      return token;
    }
  }

  String getTokenWithPrefix(token) {
    return (token != 'DFI' && token != 'DUSD') ? 'd' + token : token;
  }

  bool isPair(symbol) {
    return symbol.contains('-');
  }

  double getAmountByUsd(
      List<dynamic> tokensPairs, double amount, String token) {
    String symbol = 'USDT-DFI';
    String testnetSymbol = 'DFI-USDT';

    try {
      AssetPairModel assetPair = tokensPairs.firstWhere((element) =>
          element.symbol! == symbol || element.symbol! == testnetSymbol);
      if (token == 'DFI') {
        return assetPair.reserveADivReserveB! * amount;
      }
      AssetPairModel targetPair = tokensPairs
          .firstWhere((item) {
          return item.tokenA == token && (item.tokenB == 'DFI' || item.tokenB == 'DUSD');
      });

      double dfiByUsd = assetPair.reserveADivReserveB!;
      double dfiByToken = targetPair.reserveBDivReserveA!;

      double result;
      if (targetPair.tokenB == 'DUSD') {
        result = (dfiByToken * amount);
        return result;
      } else {
        double result = (dfiByToken * amount) * dfiByUsd;
        return result;
      }
    } catch (err) {
      // TODO: need review for return value when throw error
      return 0.00;
    }
  }

  double getAmountByBtc(
      List<dynamic> tokensPairs, double amount, String token) {
    String symbol = 'BTC-DFI';
    String testnetSymbol = 'DFI-BTC';

    try {
      AssetPairModel assetPair = tokensPairs.firstWhere((element) =>
      element.symbol! == symbol || element.symbol! == testnetSymbol);
      if (token == 'DFI') {
        return assetPair.reserveADivReserveB! * amount;
      }
      AssetPairModel targetPair = tokensPairs
          .firstWhere((item) {
        return item.tokenA == token && (item.tokenB == 'DFI' || item.tokenB == 'BTC');
      });

      double dfiByUsd = assetPair.reserveADivReserveB!;
      double dfiByToken = targetPair.reserveBDivReserveA!;

      double result;
      if (targetPair.tokenB == 'BTC') {
        result = (dfiByToken * amount);
        return result;
      } else {
        double result = (dfiByToken * amount) * dfiByUsd;
        return result;
      }
    } catch (err) {
      // TODO: need review for return value when throw error
      return 0.00;
    }
  }

  double getAmountByDfi(
      List<dynamic> tokensPairs, double amount, String baseAsset) {
    try {
      if (baseAsset == 'DFI') {
        return amount;
      } else {
        AssetPairModel assetPair =
        tokensPairs.firstWhere((element) =>
            element.tokenA! == baseAsset && !element.tokenB!.contains('v1'));
        return assetPair.reserveBDivReserveA! * amount;
      }
    } catch (err) {
      return 0.00;
    }
  }

  double getPairsAmountByAsset(
    List<dynamic> tokensPairs,
    double amount,
    String symbol,
    String resultAsset,
  ) {
    AssetPairModel assetPair =
      tokensPairs.firstWhere((element) => element.symbol! == symbol);
    double baseBalance = getBaseBalance(amount, assetPair);
    double quoteBalance = getQuoteBalance(amount, assetPair);
    double baseBalanceByAsset;
    double quoteBalanceByAsset;

    String baseAsset = symbol.split('-')[0];
    String quoteAsset = symbol.split('-')[1];

    if (resultAsset == 'USD') {
      baseBalanceByAsset =
          getAmountByUsd(tokensPairs, baseBalance, baseAsset);
      quoteBalanceByAsset =
          getAmountByUsd(tokensPairs, quoteBalance, quoteAsset);
    } else if (resultAsset == 'BTC') {
      baseBalanceByAsset =
        getAmountByBtc(tokensPairs, baseBalance, baseAsset);
      quoteBalanceByAsset =
        getAmountByBtc(tokensPairs, quoteBalance, quoteAsset);
    } else {
      baseBalanceByAsset =
          getAmountByDfi(tokensPairs, baseBalance, baseAsset);
      quoteBalanceByAsset =
          getAmountByDfi(tokensPairs, quoteBalance, quoteAsset);
    }

    return baseBalanceByAsset + quoteBalanceByAsset;
  }

  double getBaseBalance(balance, assetPair) {
    double result =
        balance * (1 / assetPair!.totalLiquidityRaw) * assetPair.reserveA!;
    return result;
  }

  double getQuoteBalance(balance, assetPair) {
    double result =
        balance * (1 / assetPair!.totalLiquidityRaw) * assetPair.reserveB!;
    return result;
  }

  String getAprFormat(double apr) {
    dynamic result;

    if (apr != 0) {
      result = '${(apr * 100).toStringAsFixed(2)}%';
    } else {
      result = 'N/A';
    }
    return '$result';
  }
}