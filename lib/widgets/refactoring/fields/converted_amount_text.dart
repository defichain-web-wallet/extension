import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConvertedAmountText extends StatelessWidget {
  final double? amount;
  final TokenModel token;

  const ConvertedAmountText({
    super.key,
    this.amount,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatesCubit, RatesState>(
      buildWhen: (prev, current) => current.status == RatesStatusList.success,
      builder: (context, ratesState) {
        late double convertedBalance;
        late String roundedAmount;
        try {
          convertedBalance = ratesState.ratesModel!.getAmountByToken(
            amount!,
            token,
          );
        } catch (_) {
          convertedBalance = 0.00;
        } finally {
          roundedAmount = BalancesHelper().numberStyling(
            convertedBalance,
            fixed: true,
            fixedCount: convertedBalance == 0 ? 2 : 6,
          );
        }

        return Text(
          roundedAmount,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .textTheme
                    .headline6!
                    .color!
                    .withOpacity(0.3),
              ),
        );
      },
    );
  }
}
