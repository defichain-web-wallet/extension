import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class MnemonicWord extends StatelessWidget {
  final int index;
  final String word;

  const MnemonicWord({
    Key? key,
    required this.index,
    required this.word,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.portage.withOpacity(0.12),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: index.toString(),
              style: Theme.of(context).textTheme.bodyText2!.apply(
                    color: AppColors.portage.withOpacity(0.5),
                  ),
            ),
            WidgetSpan(
              child: SizedBox(
                width: 6,
              ),
            ),
            TextSpan(
              text: word,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}
