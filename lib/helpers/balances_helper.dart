import 'package:basic_utils/basic_utils.dart';
import 'package:defi_wallet/models/address_balance_model.dart';
import 'package:defi_wallet/models/balance_model.dart';

class BalancesHelper {
  static const int COIN = 100000000;

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

  int getBalanceByTokenName(List<AddressBalanceModel> addressBalanceList, String token){
    var sum = 0;
    addressBalanceList.forEach((addressBalanceModel) {
      addressBalanceModel.balanceList!.forEach((balanceModel) {
        if(token == balanceModel.token){
          sum += balanceModel.balance!;
        }
      });
    });
    return sum;
  }

  List<AddressBalanceModel> updateBalance(List<AddressBalanceModel> addressBalanceList, String address, String token, int deltaBalance){
    for(var i = 0; i < addressBalanceList.length; i++){
      if(addressBalanceList[i].address == address){
        for(var j = 0; j < addressBalanceList[i].balanceList!.length; j++){
          if(addressBalanceList[i].balanceList![j].token == token){
            addressBalanceList[i].balanceList![j].balance = addressBalanceList[i].balanceList![j].balance! + deltaBalance;
          }
        }
      }
    }
    return addressBalanceList;
  }

  int toSatoshi(String balance){
    double amount = double.tryParse(balance)!;

    return  (amount * COIN).round();
  }

  double fromSatohi(int amount){
    return amount / COIN;
  }

  String numberStyling(double number, {bool fixed = false, int fixedCount = 2}){
    const double minAmountByFixed = 0.0001;
    int _fixedCount = fixedCount;
    if (number < minAmountByFixed && number != 0) {
      _fixedCount = 6;
    }
    var string = fixed ? number.toStringAsFixed(_fixedCount) : number.toString();
    var stringList = string.split('.');

    stringList[0] = StringUtils.addCharAtPosition(stringList[0].split('').reversed.join(), ",", 3, repeat: true).split('').reversed.join();
    return stringList.join('.');
  }
}
