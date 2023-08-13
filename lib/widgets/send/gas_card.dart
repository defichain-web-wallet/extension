import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class GasCard extends StatelessWidget {
  final String assetName;
  final String amount;
  final double convertedAmount;

  const GasCard({
    super.key,
    required this.assetName,
    required this.amount,
    required this.convertedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Estimated gas fee',
                    style:
                    Theme.of(context).textTheme.headline5!.copyWith(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .headline5!
                          .color!
                          .withOpacity(0.3),
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      // TextSpan(
                      //   text: '\$$convertedAmount  ',
                      //   style: Theme.of(context).textTheme.headline5!.copyWith(
                      //     fontSize: 12,
                      //   ),
                      // ),
                      TextSpan(
                        text: '$amount $assetName',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.lavenderPurple.withOpacity(0.16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Max Fee',
                  style:
                  Theme.of(context).textTheme.headline5!.copyWith(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .headline5!
                        .color!
                        .withOpacity(0.3),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Max fee:  ',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '$amount $assetName',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
