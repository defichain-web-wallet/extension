import 'package:defi_wallet/helpers/balances_helper.dart';

enum FormatNumberType {fiat, btc}

mixin FormatMixin {
  final BalancesHelper balancesHelper = BalancesHelper();

  String formatNumberStyling(double number, FormatNumberType type) {
    return balancesHelper.numberStyling(number, type: type);
  }
}