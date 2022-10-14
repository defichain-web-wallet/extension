import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/widgets/network/list_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwapAccountSelector extends StatefulWidget {
  final bool isFullSize;
  final Function(int) callback;
  final AccountModel account;

  const SwapAccountSelector({
    Key? key,
    required this.isFullSize,
    required this.callback,
    required this.account,
  }) : super(key: key);

  @override
  State<SwapAccountSelector> createState() => _SwapAccountSelectorState();
}

class _SwapAccountSelectorState extends State<SwapAccountSelector> {
  @override
  Widget build(BuildContext context) {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(10),
            contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 34.0),
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/tokens/bitcoin.svg',
                  height: 26,
                  width: 26,
                ),
                SizedBox(
                  width: 16,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Select the account you want to swap from",
                    style: Theme.of(context).textTheme.headline3,
                  )
                ])
              ],
            ),
            content: Builder(
              builder: (context) {
                var width = widget.isFullSize
                    ? MediaQuery.of(context).size.width * 0.4
                    : MediaQuery.of(context).size.width;

                return Container(
                  width: width - 16,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: ListBody(
                        children: List<Widget>.generate(
                            accountCubit.state.accounts!.length, (index) {
                          return Column(
                            children: [
                              ListEntry(
                                updateTokens: false,
                                label:
                                    '${accountCubit.state.accounts![index].name}',
                                callback: () {
                                  Navigator.of(context).pop();
                                  widget.callback(index);
                                },
                              ),
                              if (index <
                                  accountCubit.state.accounts!.length - 1)
                                Divider(
                                  height: 0,
                                  color: Theme.of(context).dividerColor,
                                )
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showMyDialog(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.account.name!,
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
