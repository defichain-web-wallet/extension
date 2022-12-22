import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:flutter/material.dart';

class BalanceText extends StatefulWidget {
  final double balance;
  final String assetName;

  const BalanceText({
    Key? key,
    required this.balance,
    required this.assetName,
  }) : super(key: key);

  @override
  State<BalanceText> createState() => _BalanceTextState();
}

class _BalanceTextState extends State<BalanceText> {
  BalancesHelper balancesHelper = BalancesHelper();
  late double totalBalance;
  late String roundedPart;
  late String decimalPart;

  @override
  void initState() {
    super.initState();
  }

  String getFormatBalance() {
    if (widget.assetName == 'USD') {
      return '\$' + roundedPart + '.';
    } else if (widget.assetName == 'EUR') {
      return '€' + roundedPart + '.';
    } else {
      return balancesHelper.numberStyling(
            totalBalance,
            fixed: true,
            fixedCount: 6,
          ) +
          ' ';
    }
  }

  Color _getBalanceTextColor(BuildContext context) {
    return (totalBalance == 0)
        ? Theme.of(context).textTheme.headline1!.color!.withOpacity(0.3)
        : Theme.of(context).textTheme.headline1!.color!;
  }

  @override
  Widget build(BuildContext context) {
    totalBalance = widget.balance;
    List<String> temp;
    if (totalBalance == 0) {
      temp = ['0', '00'];
    } else {
      temp = totalBalance.toString().split('.');
    }

    roundedPart = balancesHelper.numberStyling(double.parse(temp[0]));
    decimalPart = temp[1].substring(0, 2);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: getFormatBalance(),
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: _getBalanceTextColor(context),
                ),
          ),
          TextSpan(
            text: widget.assetName == 'BTC' ? 'BTC' : decimalPart,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _getBalanceTextColor(context),
                ),
          ),
        ],
      ),
    );
  }
}
