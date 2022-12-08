import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/my_app.dart';
import 'package:defi_wallet/screens/auth/congratulations_screen.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/name_account/name_account.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

class NameAccountScreen extends StatefulWidget {
  const NameAccountScreen({Key? key}) : super(key: key);

  @override
  State<NameAccountScreen> createState() => _NameAccountScreenState();
}

class _NameAccountScreenState extends State<NameAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(
            progress: 1,
          ),
          body: Container(
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 34,
                        child: Text(
                          'Name your account',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      NameAccount(width: 312),
                    ],
                  ),
                ),
                NewPrimaryButton(
                  callback: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          CongratulationsScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  ),
                  width: 280,
                  title: 'Continue',
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
