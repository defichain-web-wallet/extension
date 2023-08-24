import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReviewDetails extends StatelessWidget {
  final String? tokenImgUrl;
  final String? amountStyling;
  final String? currency;
  final bool isBtc;

  const ReviewDetails({
    Key? key,
    this.tokenImgUrl,
    this.amountStyling,
    this.currency,
    this.isBtc = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TokensHelper tokensHelper = TokensHelper();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Theme.of(context).textTheme.button!.decorationColor!),
        color: Theme.of(context).cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  tokenImgUrl!,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  amountStyling!,
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  isBtc ? currency! : tokensHelper.getTokenWithPrefix(currency),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
