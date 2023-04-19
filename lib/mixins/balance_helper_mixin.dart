import 'package:defi_wallet/helpers/balances_helper.dart';

mixin BalanceHelperMixin {
  final BalancesHelper balancesHelper = BalancesHelper();

  String numberStyling(double number, String type) {
    return balancesHelper.numberStyling(number, type: type);
  }
}