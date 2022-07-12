import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';

class UnstakeConfirmScreen extends StatefulWidget {
  const UnstakeConfirmScreen({Key? key}) : super(key: key);

  @override
  _UnstakeConfirmScreenState createState() => _UnstakeConfirmScreenState();
}

class _UnstakeConfirmScreenState extends State<UnstakeConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldConstrainedBoxNew(
      appBar: MainAppBar(
        title: 'Unstake',
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Do you really want to unstake?',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  '719 DFI',
                  style: Theme.of(context).textTheme.headline6!.apply(fontSizeFactor: 2),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AccentButton(
                    label: 'Cancel',
                    callback: () => Navigator.of(context).pop()),
              ),
              SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: 'Unstake',
                  isCheckLock: false,
                  callback: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              UnstakeConfirmScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
