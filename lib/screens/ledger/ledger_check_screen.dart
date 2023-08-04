import 'dart:ui';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/ledger/ledger_error_dialog.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';

class LedgerCheckScreen extends StatefulWidget {
  final Function(dynamic parent, BuildContext context) onStartSign;

  const LedgerCheckScreen({Key? key, required this.onStartSign})
      : super(key: key);

  @override
  State<LedgerCheckScreen> createState() => _LedgerCheckScreenState();
}

class _LedgerCheckScreenState extends State<LedgerCheckScreen> with ThemeMixin {
  String titleText = 'Ledger';

  bool isCloseDisabled = false;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
          backgroundColor: isDarkTheme()
              ? DarkColors.drawerBgColor
              : LightColors.drawerBgColor,
          contentPadding: EdgeInsets.only(
            top: 22,
            bottom: 24,
            left: 16,
            right: 16,
          ),
          content: Container(
            width: 300,
            height: 450,
            child: Stack(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isCloseDisabled)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.5),
                        ),
                      ),
                    )
                ],
              ),
              Center(
                child: StretchBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                titleText,
                                style: headline2.copyWith(
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 68,
                          ),
                          Image.asset(
                            'assets/images/ledger_light.png',
                            width: 296,
                            height: 114,
                          ),
                          SizedBox(
                            height: 63,
                          ),
                          Text(
                            'Now connect your Ledger device',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.6),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Only if Ledger is not connected already!',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: AppColors.pinkColor,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          PendingButton('Start',
                              pendingText: 'Sign on your ledger',
                              isCheckLock: false, callback: (parent) async {
                            parent.emitPending(true);
                            setState(() {
                              isCloseDisabled = true;
                            });
                            try {
                              await this.widget.onStartSign(parent, context);

                              Navigator.pop(context);
                            } catch (error) {
                              print(error);
                              showDialog(
                                barrierColor:
                                    AppColors.tolopea.withOpacity(0.06),
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return LedgerErrorDialog(
                                      error: error as Exception);
                                },
                              );
                            } finally {
                              parent.emitPending(false);
                              setState(() {
                                isCloseDisabled = false;
                              });
                            }
                          })
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]),
          )),
    );
  }
}
