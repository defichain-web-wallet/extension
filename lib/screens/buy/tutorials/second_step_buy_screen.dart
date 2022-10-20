import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/buy/tutorials/third_step_buy_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecondStepBuyScreen extends StatefulWidget {
  bool isConfirm;

  SecondStepBuyScreen({
    Key? key,
    this.isConfirm = false,
  }) : super(key: key);

  @override
  _SecondStepBuyScreenState createState() => _SecondStepBuyScreenState();
}

class _SecondStepBuyScreenState extends State<SecondStepBuyScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (BuildContext context, state) {
        if (state.status == AccountStatusList.success) {
          return ScaffoldConstrainedBox(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                      title: 'How does it work?',
                    ),
                    body: _buildBody(state),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'How does it work?',
                        isSmall: true,
                      ),
                      body: _buildBody(state, isFullSize: true),
                    ),
                  );
                }
              },
            ),
          );
        } else
          return Container();
      },
    );
  }

  Widget _buildBody(state, {isFullSize = false}) => Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding:
            const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
        child: Center(
          child: StretchBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: !isFullSize ? 200 : 400,
                          padding: EdgeInsets.only(
                            top: 44,
                          ),
                          child: Image(
                            image:
                                AssetImage('assets/second_step_buy_logo.png'),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 44,
                          ),
                          child: Text(
                            '2. Make a bank transfer to our partner DFX AG for the purchase.',
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline2?.apply(
                                  fontSizeFactor: 1.6,
                                ),
                          ),
                        ),
                        Container(
                          width: 320,
                          padding: EdgeInsets.only(
                            top: 44,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 217,
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: 'Next',
                        isCheckLock: false,
                        callback: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        ThirdStepBuyScreen(
                                  isConfirm: widget.isConfirm,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));
                        },
                      ),
                      Container(
                        height: 48,
                        padding: EdgeInsets.only(top: 10),
                        child: StretchBox(
                          child: Row(
                            children: [
                              Checkbox(
                                value: widget.isConfirm,
                                activeColor: AppTheme.pinkColor,
                                onChanged: (newValue) {
                                  setState(() {
                                    widget.isConfirm = !widget.isConfirm;
                                  });
                                },
                              ),
                              Flexible(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Don´t show this guide next time',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      setState(
                                        () {
                                          widget.isConfirm = !widget.isConfirm;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
