import 'package:defi_wallet/helpers/balances_helper.dart';

enum FormatNumberType { fiat, crypto }

mixin FormatMixin {
  final BalancesHelper balancesHelper = BalancesHelper();

  String formatNumberStyling(
    double number, {
    FormatNumberType type = FormatNumberType.crypto,
    int? fixedCount,
  }) {
    if (fixedCount != null)
      return balancesHelper.numberStyling(
        number,
        fixed: true,
        fixedCount: fixedCount,
      );
    else
      return balancesHelper.numberStyling(number, type: type);
  }
}
