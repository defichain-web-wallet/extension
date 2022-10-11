import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:flutter/material.dart';

class StatusTransaction extends StatelessWidget {
  TxErrorModel? txResponse;

  StatusTransaction({
    Key? key,
    this.txResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Image.asset(
            txResponse!.isError
                ? 'assets/error_gif.gif'
                : 'assets/status_reload_icon.png',
            height: 106,
            width: 104,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  txResponse!.isError
                      ? 'Transaction failed'
                      : 'Transaction successful!',
                  style: Theme.of(context).textTheme.headline1!.apply(
                    fontSizeFactor: 0.9,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  txResponse!.isError
                      ? 'Were not transaction successfully'
                      : 'Your transaction will now be processed in the background. Your account balance will be updated in a few minutes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
