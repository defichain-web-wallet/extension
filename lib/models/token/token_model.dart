import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:defi_wallet/models/network/network_name.dart';

class TokenModel {
  String id;
  String symbol;
  String name;
  String displaySymbol;
  NetworkName networkName;
  bool isUTXO;
  late bool isPair;
  late Color color;
  late String imagePath;

  TokenModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.displaySymbol,
    required this.networkName,
    this.isUTXO = false,
  }) {
    this.isPair = this.symbol.contains('-');
    this.color = getColorByTokenName(symbol: this.symbol);
    this.imagePath = getImagePath(symbol: this.symbol);
  }

  bool compare(TokenModel otherToken) {
    return this.id == otherToken.id &&
        this.networkName == otherToken.networkName &&
        this.name == otherToken.name;
  }

  factory TokenModel.fromJSON(
      Map<String, dynamic> json, NetworkName? networkName) {
    return TokenModel(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      displaySymbol: json['displaySymbol'],
      networkName: networkName ?? json['networkName'],
    );
  }

  static List<TokenModel> fromJSONList(
      List<dynamic> jsonList, NetworkName? networkName) {
    List<TokenModel> tokens = [];

    jsonList.forEach((json) {
      TokenModel token = TokenModel.fromJSON(json, networkName);
      tokens.add(token);
    });

    return tokens;
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': this.id,
      'symbol': this.symbol,
      'name': this.name,
      'displaySymbol': this.displaySymbol,
      'networkName': this.networkName,
    };
  }

  Color getColorByTokenName({String? symbol}) {
    symbol ??= this.symbol;
    switch (symbol) {
      case 'DFI':
        {
          return Color(0xFFFF00AF);
        }
      case 'ETH':
        {
          return Color(0xFF627EEA);
        }
      case 'BTC':
        {
          return Color(0xFFF7931A);
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
          final _random = Random();
          if (symbol.contains('-')) {
            String baseToken = symbol.split('-')[0];
            return getColorByTokenName(symbol: baseToken).withOpacity(0.3);
          } else {
            return Color.fromARGB(_random.nextInt(256), _random.nextInt(128),
                _random.nextInt(256), _random.nextInt(256));
          }
        }
    }
  }

  String getImagePath({String? symbol}) {
    symbol ??= this.symbol;
    switch (symbol) {
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
}
