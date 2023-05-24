import 'package:basic_utils/basic_utils.dart';
import 'package:defi_wallet/mixins/format_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_balance_model.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:flutter/material.dart';

class BalancesHelper {
  static const int COIN = 100000000;
  static const int DUST = 3000; //TODO: move to constants file
  static const int FEE = 3000; //TODO: move to constants file

  Future<double> getAvailableBalance(
      String currency, TxType type, AccountModel account) async {
    var addressBalanceList = await BalanceRequests()
        .getAddressBalanceListByAddressList(account.addressList!);
    if (currency == 'DFI') {
      var tokenDFIbalance = getBalanceByTokenName(addressBalanceList, 'DFI');

      var coinDFIbalance = getBalanceByTokenName(addressBalanceList, '\$DFI');
      switch (type) {
        case TxType.send:
          if (tokenDFIbalance > FEE) {
            return fromSatohi(coinDFIbalance + tokenDFIbalance - (FEE * 2));
          } else {
            return fromSatohi(coinDFIbalance - (FEE));
          }
        case TxType.swap:
          if (coinDFIbalance > (FEE * 2) + DUST) {
            return fromSatohi(coinDFIbalance + tokenDFIbalance - (FEE * 2));
          } else {
            return fromSatohi(tokenDFIbalance);
          }
        case TxType.addLiq:
          if (coinDFIbalance > (FEE * 2) + DUST) {
            return fromSatohi(coinDFIbalance + tokenDFIbalance - (FEE * 2));
          } else {
            return fromSatohi(tokenDFIbalance);
          }
        default:
          return 0;
      }
    } else {
      return fromSatohi(getBalanceByTokenName(addressBalanceList, currency));
    }
  }

  List<BalanceModel> findAndSumDuplicates(List<BalanceModel> balanceList) {
    List<BalanceModel> newBalanceList = [];
    var balanceMap = {};
    balanceList.forEach((balanceModel) {
      if (balanceMap.containsKey(balanceModel.token!)) {
        balanceMap[balanceModel.token!] += balanceModel.balance!;
      } else {
        balanceMap[balanceModel.token!] = balanceModel.balance!;
      }
    });
    balanceMap.keys.forEach((key) {
      newBalanceList.add(BalanceModel(token: key, balance: balanceMap[key]));
    });
    return newBalanceList;
    // return balanceMap.map((balance)=>BalanceModel(token: balance));
  }

  List<double> calculateAmountFromLiqudity(int amount, AssetPairModel pair) {
    var amountA = (amount / pair.totalLiquidityRaw!) * pair.reserveA!;
    var amountB = (amount / pair.totalLiquidityRaw!) * pair.reserveB!;
    return [amountA, amountB];
  }

  int getBalanceByTokenName(
      List<AddressBalanceModel> addressBalanceList, String token) {
    var sum = 0;
    addressBalanceList.forEach((addressBalanceModel) {
      addressBalanceModel.balanceList!.forEach((balanceModel) {
        if (token == balanceModel.token) {
          sum += balanceModel.balance!;
        }
      });
    });
    return sum;
  }

  List<AddressBalanceModel> updateBalance(
      List<AddressBalanceModel> addressBalanceList,
      String address,
      String token,
      int deltaBalance) {
    for (var i = 0; i < addressBalanceList.length; i++) {
      if (addressBalanceList[i].address == address) {
        for (var j = 0; j < addressBalanceList[i].balanceList!.length; j++) {
          if (addressBalanceList[i].balanceList![j].token == token) {
            addressBalanceList[i].balanceList![j].balance =
                addressBalanceList[i].balanceList![j].balance! + deltaBalance;
          }
        }
      }
    }
    return addressBalanceList;
  }

  int toSatoshi(String balance) {
    double amount = double.tryParse(balance)!;

    return (amount * COIN).round();
  }

  double fromSatohi(int amount) {
    return amount / COIN;
  }

  String numberStyling(
    double number, {
    bool fixed = false,
    bool isFormatRounded = false,
    int fixedCount = 2,
    FormatNumberType? type,
  }) {
    double minNumber = 0.000001;
    if (type == null) {
      var stringNumber = '';

      if (number < minNumber && !fixed && number != 0) {
        stringNumber = number.toStringAsFixed(8);
      } else {
        stringNumber =
            fixed ? number.toStringAsFixed(fixedCount) : number.toString();
      }
      var charNumberList = stringNumber.split('.');

      if (isFormatRounded) {
        int separatedCount = number >= 1000000 ? 2 : 3;
        var temp = StringUtils.addCharAtPosition(
            charNumberList.first.split('').reversed.join(), ',', separatedCount,
            repeat: true)
            .split('')
            .reversed
            .join();
        var separatedNumbers = temp.split(',');
        if (number >= 1000000) {
          return '${separatedNumbers[0]}.${separatedNumbers[1]}M';
        } else if (number >= 1000) {
          return '${separatedNumbers[0]}K';
        }
      }
      charNumberList.first = StringUtils.addCharAtPosition(
          charNumberList.first.split('').reversed.join(), ",", 3,
          repeat: true)
          .split('')
          .reversed
          .join();
      return charNumberList.join('.');
    } else {
      return numberSpecificFormat(type, number);
    }
  }

  String numberSpecificFormat(
    FormatNumberType? type,
    double number,
  ) {
    int specificPrecision = type == FormatNumberType.crypto ? 4 : 5;
    int defaultPrecision = type == FormatNumberType.crypto ? 2 : 4;
    switch (type) {
      case FormatNumberType.fiat:
        return trimTrailingZeros(
          numberStyling(
            number,
            fixedCount: 2,
            fixed: true,
          ),
          type: FormatNumberType.fiat,
        );
      case FormatNumberType.btc:
      case FormatNumberType.crypto:
        if (number == 0) {
          return trimTrailingZeros(
            numberStyling(
              number,
              fixedCount: 6,
              fixed: true,
            ),
          );
        } else if (number < 1) {
          return trimTrailingZeros(
            numberStyling(
              number,
              fixedCount: 6,
              fixed: true,
            ),
          );
        } else if (number < 10 && number >= 1) {
          return trimTrailingZeros(
            numberStyling(
              number,
              fixedCount: specificPrecision,
              fixed: true,
            ),
          );
        } else {
          return trimTrailingZeros(
            numberStyling(
              number,
              fixedCount: defaultPrecision,
              fixed: true,
            ),
          );
        }
      default:
        return numberStyling(number);
    }
  }

  String trimTrailingZeros(String str, {FormatNumberType? type}) {
    int index = str.length - 1;
    while (index >= 0 && (str[index] == '0' || str[index] == '.')) {
      index--;
    }
    if (double.tryParse(str) == 0) {
      if (type == FormatNumberType.fiat) {
        return '0.00';
      } else {
        return '0';
      }
    } else {
      return str.substring(0, index + 1);
    }
  }

  bool isAmountEmpty(String amount) {
    return (amount == '0' || amount == '0.0' || amount == '');
  }
}
