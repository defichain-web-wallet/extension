import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:flutter/material.dart';

class AvailableAmountText extends StatelessWidget {
  final double amount;

  const AvailableAmountText({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final roundedAmount = BalancesHelper().numberStyling(
      amount,
      fixed: true,
      fixedCount: 8,
    );

    return Text(
      'Available: $roundedAmount',
      style: Theme.of(context).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3),
          ),
    );
  }
}
