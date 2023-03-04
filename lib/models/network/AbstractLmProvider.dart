import 'package:defi_wallet/models/token_model.dart';

import '../token_model.dart';
import 'AbstractAccount.dart';

class LmPool {
  List<TokensModel> tokens;
  List<double> percentages;
  double? apr;
  double? apy;
  LmPool(this.tokens, this.percentages, this.apr, this.apy);
}

abstract class AbstractLmProvider {
  List<LmPool> getAvailableLmPools();
  List<LmPool> getPinnedLmPools(AbstractAccount account);
  void pinLmPool(AbstractAccount account, LmPool pool);
  void unpinLmPool(AbstractAccount account, LmPool pool);

  String addBalance(AbstractAccount account, String password, LmPool pool,
      TokensModel token, double amount);
  String removeBalance(
      AbstractAccount account, String password, LmPool pool, double percentage);
}
