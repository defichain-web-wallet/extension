import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class SwapPriceDetails extends StatelessWidget {
  final String? feeDetails;
  final String? priceToDetails;
  final String? priceFromDetails;

  const SwapPriceDetails(
      {Key? key, this.feeDetails, this.priceToDetails, this.priceFromDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price',
              style: Theme.of(context).textTheme.headline6,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceFromDetails!,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 4),
                Text(
                  priceToDetails!,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: AppTheme.lightGreyColor),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fee',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              feeDetails!,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: AppTheme.lightGreyColor),
        ),
      ],
    );
  }
}
