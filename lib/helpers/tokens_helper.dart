import 'dart:math' as math;
import 'dart:ui';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:flutter/material.dart';

class TokensHelper {
  static const String DefiAccountSymbol = 'DFI';
  static const String DefiTokenSymbol = '\$DFI';
  final _random = math.Random();

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

  String? getImagePathByTokenName(tokenName) {
    switch (tokenName) {
      case 'DFI':
        {
          return 'assets/images/tokens/dfi.png';
        }
      case 'ETH':
        {
          return 'assets/images/tokens/eth.png';
        }
      case 'BTC':
        {
          return 'assets/images/tokens/btc.png';
        }
      case 'LTC':
        {
          return 'assets/images/tokens/ltc.png';
        }
      case 'USDT':
        {
          return 'assets/images/tokens/usdt.png';
        }
      case 'BCH':
        {
          return 'assets/images/tokens/bch.png';
        }
      case 'DOGE':
        {
          return 'assets/images/tokens/doge.png';
        }
      case 'DUSD':
        {
          return 'assets/images/tokens/dusd.png';
        }
      case 'USDC':
        {
          return 'assets/images/tokens/usdc.png';
        }
      default:
        {
          return null;
        }
    }
  }

  List<Color> getColorsByTokenName(tokenName) {
    switch (tokenName) {
      case 'DFI':
        {
          return [
            Color(0xffFF00AF),
            Color(0xffBF0083),
          ];
        }
      case 'ETH':
        {
          return [
            Color(0xff627EEA),
            Color(0xff3C61F1),
          ];
        }
      case 'BTC':
        {
          return [
            Color(0xffF7931A),
            Color(0xffE2820F),
          ];
        }
      case 'LTC':
        {
          return [
            Color(0xff3A69B1),
            Color(0xff2D528B),
          ];
        }
      case 'USDT':
        {
          return [
            Color(0xff499F88),
            Color(0xff5BC1A5),
          ];
        }
      case 'BCH':
        {
          return [
            Color(0xff08AE80),
            Color(0xff0CCD97),
          ];
        }
      case 'DOGE':
        {
          return [
            Color(0xffAE9530),
            Color(0xffC7AA37),
          ];
        }
      case 'DUSD':
        {
          return [
            Color(0xffF001A5),
            Color(0xffF001A5),
          ];
        }
      case 'USDC':
        {
          return [
            Color(0xff287BD6),
            Color(0xff256BB7),
          ];
        }
      case 'SPY':
        {
          return [
            Color(0xff587E4C),
            Color(0xff587E4C),
          ];
        }
      case 'FB':
        {
          return [
            Color(0xff4867AA),
            Color(0xff405C97),
          ];
        }
      case 'XLRE':
        {
          return [
            Color(0xff385949),
            Color(0xff273E33),
          ];
        }
      case 'PG':
        {
          return [
            Color(0xff0068C0),
            Color(0xff0363B5),
          ];
        }
      case 'JNJ':
        {
          return [
            Color(0xffD51900),
            Color(0xffC51700),
          ];
        }
      case 'GSD':
        {
          return [
            Color(0xffC10F1C),
            Color(0xffAE0E1A),
          ];
        }
      case 'GOOGL':
        {
          return [
            Color(0xff4080EB),
            Color(0xff4184F3),
          ];
        }
      case 'GME':
        {
          return [
            Color(0xffED3427),
            Color(0xffD32D21),
          ];
        }
      case 'ARKK':
        {
          return [
            Color(0xff775BEB),
            Color(0xff684FD1),
          ];
        }
      case 'KO':
        {
          return [
            Color(0xffF40009),
            Color(0xffE00109),
          ];
        }
      case 'COIN':
        {
          return [
            Color(0xff0052FF),
            Color(0xff024EED),
          ];
        }
      case 'TLT':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'TSLA':
        {
          return [
            Color(0xffC32F46),
            Color(0xffB42B40),
          ];
        }
      case 'BABA':
        {
          return [
            Color(0xffF56A0C),
            Color(0xffD95C09),
          ];
        }
      case 'VOO':
        {
          return [
            Color(0xffA51B23),
            Color(0xff96151D),
          ];
        }
      case 'ADDYY':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'UNG':
        {
          return [
            Color(0xff72B7E0),
            Color(0xff6BADD4),
          ];
        }
      case 'PPLT':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'QQQ':
        {
          return [
            Color(0xff323D9F),
            Color(0xff2A3384),
          ];
        }
      case 'ARKK':
        {
          return [
            Color(0xff7A5DF0),
            Color(0xff6E55D9),
          ];
        }
      case 'INTC':
        {
          return [
            Color(0xff0068B5),
            Color(0xff0260A6),
          ];
        }
      case 'SAP':
        {
          return [
            Color(0xff007DB8),
            Color(0xff036C9E),
          ];
        }
      case 'DIS':
        {
          return [
            Color(0xff4CD8B0),
            Color(0xff44C8A2),
          ];
        }
      case 'EEM':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'AAPL':
        {
          return [
            Color(0xff828A8D),
            Color(0xff70777A),
          ];
        }
      case 'GLD':
        {
          return [
            Color(0xffD9C63D),
            Color(0xffBCAD3D),
          ];
        }
      case 'URA':
        {
          return [
            Color(0xffF14F00),
            Color(0xffDE4A01),
          ];
        }
      case 'ARKX':
        {
          return [
            Color(0xff8264FF),
            Color(0xff6F54E0),
          ];
        }
      case 'SLV':
        {
          return [
            Color(0xff949292),
            Color(0xff959595),
          ];
        }
      case 'USO':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'NVDA':
        {
          return [
            Color(0xff78B016),
            Color(0xff699A13),
          ];
        }
      case 'NFLX':
        {
          return [
            Color(0xffE50914),
            Color(0xffC7131C),
          ];
        }
      case 'PDBC':
        {
          return [
            Color(0xff000AD2),
            Color(0xff030CC5),
          ];
        }
      case 'GOVT':
        {
          return [
            Color(0xff0379CA),
            Color(0xff026DB6),
          ];
        }
      case 'XLE':
        {
          return [
            Color(0xff273F33),
            Color(0xff20342A),
          ];
        }
      case 'URTH':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'AMZN':
        {
          return [
            Color(0xffF09103),
            Color(0xffCB7C06),
          ];
        }
      case 'PLTR':
        {
          return [
            Color(0xff363D44),
            Color(0xff1E2124),
          ];
        }
      case 'VNQ':
        {
          return [
            Color(0xffA51B23),
            Color(0xff96151D),
          ];
        }
      case 'VBK':
        {
          return [
            Color(0xffA51B23),
            Color(0xff96151D),
          ];
        }
      case 'BRK.B':
        {
          return [
            Color(0xff000080),
            Color(0xff020268),
          ];
        }
      case 'DAX':
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
      case 'MSTR':
        {
          return [
            Color(0xffD9232E),
            Color(0xffBB1E28),
          ];
        }
      case 'CS':
        {
          return [
            Color(0xff183964),
            Color(0xff162F51),
          ];
        }
      case 'GS':
        {
          return [
            Color(0xff7399C6),
            Color(0xff6586AE),
          ];
        }
      case 'UL':
        {
          return [
            Color(0xff1F36C7),
            Color(0xff1A2FB5),
          ];
        }
      case 'TAN':
        {
          return [
            Color(0xff000AD2),
            Color(0xff0009C1),
          ];
        }
      case 'MSFT':
        {
          return [
            Color(0xff099FE4),
            Color(0xff078FCE),
          ];
        }
      case 'PYPL':
        {
          return [
            Color(0xff27346A),
            Color(0xff202B59),
          ];
        }
      case 'XOM':
        {
          return [
            Color(0xffEF000B),
            Color(0xffDA020C),
          ];
        }
      case 'WMT':
        {
          return [
            Color(0xffE8AC36),
            Color(0xffD49D2F),
          ];
        }
      case 'MCHI':
        {
          return [
            Color(0xff213A8F),
            Color(0xff1B317C),
          ];
        }
      default:
        {
          return [
            Color(0xff4B4069),
            Color(0xff1C1333),
          ];
        }
    }
  }

  List<double>? getStopsByTokenName(tokenName) {
    switch (tokenName) {
      case 'DFI':
        {
          return [0.0348, 0.942];
        }
      case 'ETH':
        {
          return [0.1028, 0.9523];
        }
      case 'BTC':
        {
          return [0, 0.9333];
        }
      case 'LTC':
        {
          return [0.0913, 0.9087];
        }
      case 'USDT':
        {
          return [0.0704, 0.9064];
        }
      case 'BCH':
        {
          return [0.0017, 0.8543];
        }
      case 'DOGE':
        {
          return [0.0781, 0.9159];
        }
      case 'DUSD':
        {
          return null;
        }
      case 'USDC':
        {
          return [0.0955, 0.9265];
        }
      case 'SPY':
        {
          return [0.1089, 0.8822];
        }
      case 'FB':
        {
          return [0.1089, 0.8822];
        }
      case 'XLRE':
        {
          return [0.1089, 0.8822];
        }
      case 'PG':
        {
          return [0.1089, 0.8822];
        }
      case 'JNJ':
        {
          return [0.1089, 0.8822];
        }
      case 'GSD':
        {
          return [0.1089, 0.8822];
        }
      case 'GOOGL':
        {
          return [0.0119, 0.8864];
        }
      case 'GME':
        {
          return [0.1089, 0.8822];
        }
      case 'ARKK':
        {
          return [0.1089, 0.8822];
        }
      case 'KO':
        {
          return [0.1089, 0.8822];
        }
      case 'COIN':
        {
          return [0.1089, 0.8822];
        }
      case 'TLT':
        {
          return [-0.02, 1];
        }
      case 'TSLA':
        {
          return [0.01242, 0.8724];
        }
      case 'BABA':
        {
          return [0.1089, 0.8822];
        }
      case 'VOO':
        {
          return [0.1089, 0.8822];
        }
      case 'ADDYY':
        {
          return [-0.02, 1];
        }
      case 'UNG':
        {
          return [0.1089, 0.8822];
        }
      case 'PPLT':
        {
          return [-0.02, 1];
        }
      case 'QQQ':
        {
          return [0.1457, 0.8627];
        }
      case 'ARKK':
        {
          return [0.1089, 0.8822];
        }
      case 'INTC':
        {
          return [0.1089, 0.8822];
        }
      case 'SAP':
        {
          return [0.1089, 0.8822];
        }
      case 'DIS':
        {
          return [0.1089, 0.8822];
        }
      case 'EEM':
        {
          return [-0.02, 1];
        }
      case 'AAPL':
        {
          return [0.1457, 0.8627];
        }
      case 'GLD':
        {
          return [0.1089, 0.8822];
        }
      case 'URA':
        {
          return [0.1089, 0.8822];
        }
      case 'ARKX':
        {
          return [0.1089, 0.8822];
        }
      case 'SLV':
        {
          return [0.1089, 0.8822];
        }
      case 'USO':
        {
          return [-0.02, 1];
        }
      case 'NVDA':
        {
          return [0.1457, 0.8627];
        }
      case 'NFLX':
        {
          return [0.1089, 0.8822];
        }
      case 'PDBC':
        {
          return [0.1089, 0.8822];
        }
      case 'GOVT':
        {
          return [0.1089, 0.8822];
        }
      case 'XLE':
        {
          return [0.1089, 0.8822];
        }
      case 'URTH':
        {
          return [-0.02, 1];
        }
      case 'AMZN':
        {
          return [0.1457, 0.8627];
        }
      case 'PLTR':
        {
          return [0.1089, 0.8822];
        }
      case 'VNQ':
        {
          return [0.1089, 0.8822];
        }
      case 'VBK':
        {
          return [0.1089, 0.8822];
        }
      case 'BRK.B':
        {
          return [0.1089, 0.8822];
        }
      case 'DAX':
        {
          return [-0.02, 1];
        }
      case 'MSTR':
        {
          return [0.1457, 0.8627];
        }
      case 'CS':
        {
          return [0.1089, 0.8822];
        }
      case 'GS':
        {
          return [0.1089, 0.8822];
        }
      case 'UL':
        {
          return [0.1089, 0.8822];
        }
      case 'TAN':
        {
          return [0.1089, 0.8822];
        }
      case 'MSFT':
        {
          return [0.1457, 0.8627];
        }
      case 'PYPL':
        {
          return [0.1089, 0.8822];
        }
      case 'XOM':
        {
          return [0.1089, 0.8822];
        }
      case 'WMT':
        {
          return [0.1089, 0.8822];
        }
      case 'MCHI':
        {
          return [0.1089, 0.8822];
        }
      default:
        {
          return [-0.02, 1];
        }
    }
  }

  double? getDegRotateByTokenName(tokenName) {
    switch (tokenName) {
      case 'DFI':
        {
          return 218.29;
        }
      case 'ETH':
        {
          return 219.64;
        }
      case 'BTC':
        {
          return 220.54;
        }
      case 'LTC':
        {
          return 224.43;
        }
      case 'USDT':
        {
          return 45.54;
        }
      case 'BCH':
        {
          return 112.83;
        }
      case 'DOGE':
        {
          return 47.68;
        }
      case 'DUSD':
        {
          return null;
        }
      case 'USDC':
        {
          return 225.51;
        }
      case 'SPY':
        {
          return 232.63;
        }
      case 'FB':
        {
          return 232.63;
        }
      case 'XLRE':
        {
          return 232.63;
        }
      case 'PG':
        {
          return 232.63;
        }
      case 'JNJ':
        {
          return 232.63;
        }
      case 'GSD':
        {
          return 232.63;
        }
      case 'GOOGL':
        {
          return 63.82;
        }
      case 'GME':
        {
          return 232.63;
        }
      case 'ARKK':
        {
          return 232.63;
        }
      case 'KO':
        {
          return 232.63;
        }
      case 'COIN':
        {
          return 232.63;
        }
      case 'TLT':
        {
          return 90;
        }
      case 'TSLA':
        {
          return 236.07;
        }
      case 'BABA':
        {
          return 232.63;
        }
      case 'VOO':
        {
          return 232.63;
        }
      case 'ADDYY':
        {
          return 90;
        }
      case 'UNG':
        {
          return 232.63;
        }
      case 'PPLT':
        {
          return 90;
        }
      case 'QQQ':
        {
          return 229.4;
        }
      case 'ARKK':
        {
          return 232.63;
        }
      case 'INTC':
        {
          return 232.63;
        }
      case 'SAP':
        {
          return 232.63;
        }
      case 'DIS':
        {
          return 232.63;
        }
      case 'EEM':
        {
          return 90;
        }
      case 'AAPL':
        {
          return 229.4;
        }
      case 'GLD':
        {
          return 232.63;
        }
      case 'URA':
        {
          return 232.63;
        }
      case 'ARKX':
        {
          return 232.63;
        }
      case 'SLV':
        {
          return 232.63;
        }
      case 'USO':
        {
          return 90;
        }
      case 'NVDA':
        {
          return 229.4;
        }
      case 'NFLX':
        {
          return 232.63;
        }
      case 'PDBC':
        {
          return 232.63;
        }
      case 'GOVT':
        {
          return 232.63;
        }
      case 'XLE':
        {
          return 232.63;
        }
      case 'URTH':
        {
          return 90;
        }
      case 'AMZN':
        {
          return 229.4;
        }
      case 'PLTR':
        {
          return 232.63;
        }
      case 'VNQ':
        {
          return 232.63;
        }
      case 'VBK':
        {
          return 232.63;
        }
      case 'BRK.B':
        {
          return 232.63;
        }
      case 'DAX':
        {
          return 90;
        }
      case 'MSTR':
        {
          return 229.4;
        }
      case 'CS':
        {
          return 232.63;
        }
      case 'GS':
        {
          return 232.63;
        }
      case 'UL':
        {
          return 232.63;
        }
      case 'TAN':
        {
          return 232.63;
        }
      case 'MSFT':
        {
          return 229.4;
        }
      case 'PYPL':
        {
          return 232.63;
        }
      case 'XOM':
        {
          return 232.63;
        }
      case 'WMT':
        {
          return 232.63;
        }
      case 'MCHI':
        {
          return 232.63;
        }
      default:
        {
          return 90;
        }
    }
  }

  double getRadianByDeg(double deg) {
    return deg * (math.pi / 180);
  }

  Color getColorByTokenName(tokenName) {
    switch (tokenName) {
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

  String getSpecificDefiName(String value) {
    if (!SettingsHelper.isBitcoin()) {
      String defaultDefiTokenName = 'Default Defi token';
      String defaultBitcoinTokenName = 'Bitcoin';
      return value
          .replaceAll(defaultDefiTokenName, 'DeFiChain')
          .replaceAll(defaultBitcoinTokenName, 'DeFiChain Bitcoin');
    } else {
      return value;
    }
  }

  List<TokensModel> getTokensList(
    balances,
    tokensState, {
    List<TokensModel>? targetList,
  }) {
    List<TokensModel> resList = [];
    if (targetList == null) {
      balances!.forEach((element) {
        tokensState.tokens!.forEach((el) {
          if (element.token == el.symbol) {
            resList.add(el);
          }
        });
      });
    } else {
      targetList.forEach((element) {
        tokensState.tokens!.forEach((el) {
          if (element.symbol == el.symbol) {
            resList.add(el);
          }
        });
      });
    }
    return resList;
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
    return (token != 'DFI' && token != 'DUSD' && token != 'csETH')
        ? 'd' + token
        : token;
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
      AssetPairModel targetPair = tokensPairs.firstWhere((item) {
        return item.tokenA == token &&
            (item.tokenB == 'DFI' || item.tokenB == 'DUSD');
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
      AssetPairModel targetPair = tokensPairs.firstWhere((item) {
        return item.tokenA == token &&
            (item.tokenB == 'DFI' || item.tokenB == 'BTC');
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
        AssetPairModel assetPair = tokensPairs.firstWhere((element) =>
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
    AssetPairModel assetPair = tokensPairs
        .firstWhere((element) => element.symbol! == symbol.replaceAll('d', ''));
    double baseBalance = getBaseBalance(amount, assetPair);
    double quoteBalance = getQuoteBalance(amount, assetPair);
    double baseBalanceByAsset;
    double quoteBalanceByAsset;

    String baseAsset = symbol.split('-')[0];
    String quoteAsset = symbol.split('-')[1];

    if (resultAsset == 'USD') {
      baseBalanceByAsset = getAmountByUsd(tokensPairs, baseBalance, baseAsset);
      quoteBalanceByAsset =
          getAmountByUsd(tokensPairs, quoteBalance, quoteAsset);
    } else if (resultAsset == 'BTC') {
      baseBalanceByAsset = getAmountByBtc(tokensPairs, baseBalance, baseAsset);
      quoteBalanceByAsset =
          getAmountByBtc(tokensPairs, quoteBalance, quoteAsset);
    } else {
      baseBalanceByAsset = getAmountByDfi(tokensPairs, baseBalance, baseAsset);
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

  String getAprFormat(double apr, bool isPersentSymbol) {
    dynamic result;

    if (apr != 0) {
      result =
          '${(apr * 100).toStringAsFixed(2)} ${isPersentSymbol == true ? '%' : ''}';
    } else {
      result = 'N/A';
    }
    return '$result';
  }
}
