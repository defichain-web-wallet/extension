import 'package:defi_wallet/models/token/token_model.dart';

class RampTokenModel extends TokenModel {
  final TokenModel token;

  RampTokenModel({required this.token})
      : super(
          id: token.id,
          symbol: token.symbol,
          name: token.name,
          displaySymbol: token.displaySymbol,
          networkName: token.networkName,
        );
}
