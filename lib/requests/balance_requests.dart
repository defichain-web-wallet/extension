import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/address_balance_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:http/http.dart' as http;

class BalanceRequests {
  var networkHelper = NetworkHelper();
  var tokensHelper = TokensHelper();
  var addressesHelper = AddressesHelper();
  var balancesHelper = BalancesHelper();

  Future<List<BalanceModel>> getBalanceListByAddress(String address, bool sumDFI, String network) async {
    try {
      final Uri url = Uri.parse(
        'https://ocean.defichain.com/v0/$network/address/$address/tokens');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<BalanceModel> balances = [];
        var data = jsonDecode(response.body);
        var dfiBalance = await getBalanceDFIcoinByAddress(address, sumDFI, network);
        var presentDFI = false;
        data['data'].forEach((el){
          int amount = convertToSatoshi(double.parse(el['amount']));
          if(tokensHelper.isDfiToken(el['symbol'])){
            if(sumDFI){
              presentDFI = true;
              amount = amount + dfiBalance.balance!;
            }
          }
          balances.add(BalanceModel(token: el['symbol'], balance: amount));
        });
        if(dfiBalance.balance! > 0 || balances.length > 0){
          if(sumDFI){
            if(!presentDFI){
              dfiBalance.token = 'DFI';
              balances.add(dfiBalance);
            }
          } else {
            balances.add(dfiBalance);
          }
        }
        return balancesHelper.findAndSumDuplicates(balances);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<BalanceModel> getBalanceDFIcoinByAddress(String address, bool sumDFI, String network) async {
    try {
      final Uri url = Uri.parse(
        'https://ocean.defichain.com/v0/$network/address/$address/balance');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return BalanceModel(token: '\$DFI', balance: convertToSatoshi(double.parse(data['data'])));
      }
      return BalanceModel(token: '\$DFI', balance: 0);
    } catch (_) {
      return BalanceModel(token: '\$DFI', balance: 0);
    }
  }

  Future<List<BalanceModel>> getBalanceListByAddressList(List<AddressModel> addressList, String network) async {
    try {
      List<BalanceModel> balanceList = [];
      var addressListString = addressesHelper.getAddressStringFromListAddressModel(addressList);


      for (var address in addressListString) {
        var balances = await getBalanceListByAddress(address, true, network);
        balanceList.addAll(balances);
      }
      balanceList = balancesHelper.findAndSumDuplicates(balanceList);

      return balanceList;

    } catch (_) {
      return [];
    }
  }
  Future<List<AddressBalanceModel>> getAddressBalanceListByAddressList(List<AddressModel> addressList) async {
    try {
      List<AddressBalanceModel> balanceList = [];
      for(var i = 0; i < addressList.length; i++){

        var balances = await getBalanceListByAddress(addressList[i].address!, false, networkHelper.getNetworkString());

        balanceList.add(AddressBalanceModel(address: addressList[i].address!, balanceList: balances, addressModel: addressList[i]));
      }
      return balanceList;
    } catch (_) {
      return [];
    }
  }
}
