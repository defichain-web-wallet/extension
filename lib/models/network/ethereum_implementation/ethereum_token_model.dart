import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class EthereumTokenModel extends TokenModel {
  String contractAddress;

  EthereumTokenModel({
    required id,
    required this.contractAddress,
    required symbol,
    required name,
    required displaySymbol,
    required networkName,
    required tokenDecimals,
  }) : super(
    id: id,
    symbol: symbol,
    name: name,
    displaySymbol: displaySymbol,
    networkName: networkName,
    isUTXO: false,
    tokenDecimals: tokenDecimals,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['symbol'] = this.symbol;
    data['displaySymbol'] = this.displaySymbol;
    data['name'] = this.name;
    data['networkName'] = this.networkName.toString();
    data['contractAddress'] = this.contractAddress.toString();
    data['tokenDecimals'] = this.tokenDecimals;
    return data;
  }

  factory EthereumTokenModel.fromJSON(
      Map<String, dynamic> json) {
   return EthereumTokenModel(id: json['id'],
     contractAddress: json['contractAddress'],
     symbol: json['symbol'],
     name: json['name'],
     displaySymbol: json['displaySymbol'],
     tokenDecimals: json['tokenDecimals'],
     networkName:NetworkName.values.firstWhere(
           (value) => value.toString() == json['networkName'],
     ),
   );
  }
}
