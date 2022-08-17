import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/create_password_screen.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

class LedgerInitScreen extends StatefulWidget {
  @override
  _LedgerInitState createState() => _LedgerInitState();
}

class _LedgerInitState extends State<LedgerInitScreen> {
  @override
  Widget build(BuildContext context) {
    return AccentButton(
      label: 'Next',
      callback: () async {
        var box = await Hive.openBox(HiveBoxes.client);
        await box.put(HiveNames.walletType, "ledger");
        await box.close();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => CreatePasswordScreen(showStep: false, showDoneScreen: false, isRecovery: true),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}
