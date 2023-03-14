import 'package:defi_wallet/models/token_model.dart';
import 'abstract_account_model.dart';

class LmPool {
  List<TokensModel> tokens;
  List<double> percentages;
  double? apr;
  double? apy;
  LmPool(this.tokens, this.percentages, this.apr, this.apy);
}

abstract class AbstractLmProviderModel {
  List<LmPool> getAvailableLmPools();
  List<LmPool> getPinnedLmPools(AbstractAccountModel account);
  void pinLmPool(AbstractAccountModel account, LmPool pool);
  void unpinLmPool(AbstractAccountModel account, LmPool pool);

  String addBalance(AbstractAccountModel account, String password, LmPool pool,
      TokensModel token, double amount);
  String removeBalance(AbstractAccountModel account, String password,
      LmPool pool, double percentage);
}
