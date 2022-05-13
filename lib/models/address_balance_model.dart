import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defichaindart/defichaindart.dart';

class AddressBalanceModel {
  String? address;
  List<BalanceModel>? balanceList;
  AddressModel? addressModel;

  AddressBalanceModel({this.address, this.balanceList, this.addressModel});

  AddressBalanceModel.fromJson(Map<String, dynamic> json) {
    this.address = json["address"];

    List<BalanceModel> balanceList = [];
    json["accounts"]
        .map((data) => balanceList.add(BalanceModel.fromJson(data)))
        .toList();
    this.balanceList = balanceList;
  }
}