import 'package:defi_wallet/models/token/token_model.dart';

class StakingTokenModel extends TokenModel {
  double? apr;
  double? apy;

  StakingTokenModel(
      {required  this.apr, required  this.apy, required TokenModel token})
      : super(
      id: token.id,
      symbol: token.symbol,
      name: token.name,
      displaySymbol: token.displaySymbol,
      networkName: token.networkName,
      isUTXO: token.isUTXO);
}