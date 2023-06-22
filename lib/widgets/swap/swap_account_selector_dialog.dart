import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/account_menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwapAccountSelectorDialog extends StatefulWidget {
  final Function()? deleteCallback;
  final Function(String name, String address) confirmCallback;
  final Function(int index) onSelect;

  const SwapAccountSelectorDialog({
    Key? key,
    this.deleteCallback,
    required this.confirmCallback,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<SwapAccountSelectorDialog> createState() =>
      _SwapAccountSelectorDialog();
}

class _SwapAccountSelectorDialog extends State<SwapAccountSelectorDialog> {
  late double accountsSelectorHeight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        var accounts = state.accounts;
        if (accounts!.length == 1) {
          accountsSelectorHeight = 193;
        }
        if (accounts.length > 1) {
          accountsSelectorHeight = 256;
        }
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: AlertDialog(
            insetPadding: EdgeInsets.all(24),
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            actionsPadding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 14,
            ),
            contentPadding: EdgeInsets.only(
              top: 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            content: Container(
              width: 280,
              height: accountsSelectorHeight,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              'Account',
                              style: headline2.copyWith(
                                  fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Select the account you want to change from',
                          style:
                          Theme.of(context).textTheme.headline5!.apply(
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.6),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: ListView.builder(
                              itemCount: accounts.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    AccountMenuButton(
                                      accountSelectMode: true,
                                      callback: (index) {
                                        widget.onSelect(index);
                                        Navigator.pop(context);
                                      },
                                      // account: accounts[index],
                                      isHoverBackgroundEffect: false,
                                      iconPath: 'assets/icons/add.svg',
                                      title: accounts[index].name!,
                                    ),
                                    Divider(
                                      height: 1,
                                      endIndent: 12,
                                      indent: 12,
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.05),
                                      thickness: 1,
                                    ),
                                  ],
                                );
                              },
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
      },
    );
  }
}
