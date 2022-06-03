import 'package:defi_wallet/helpers/balances_helper.dart';

BalancesHelper balancesHelper = BalancesHelper();

int convertToSatoshi(double value) {
  return (value * 100000000).round();
}

double convertFromSatoshi(int value, [int digits = 0]) {
  int fixedDigits = (digits == 0) ? 8 : digits;
  return double.parse((value / 100000000).toStringAsFixed(fixedDigits));
}

String toFixed(double value, int digit) {
  return value.toStringAsFixed(digit);
}