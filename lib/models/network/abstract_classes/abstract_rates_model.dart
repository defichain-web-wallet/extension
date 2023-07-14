import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';

abstract class AbstractRatesModel {
  late final List<TokenModel>? tokens;
  late final List<LmPoolModel>? poolPairs;

  AbstractRatesModel(
    this.tokens,
    this.poolPairs,
  );

  loadTokens(AbstractNetworkModel network);
}
