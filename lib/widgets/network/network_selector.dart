import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/widgets/network/list_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkSelector extends StatefulWidget {
  final bool isFullSize;

  const NetworkSelector({Key? key, required this.isFullSize}) : super(key: key);

  @override
  State<NetworkSelector> createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector> {
  SettingsHelper settingsHelper = SettingsHelper();

  String getNetworkType() {
    if (SettingsHelper.isBitcoin()) {
      switch (SettingsHelper.settings.network) {
        case 'testnet':
          return "Bitcoin Testnet";
        case 'mainnet':
          return "Bitcoin Mainnet";
      }
    }
    switch (SettingsHelper.settings.network) {
      case 'testnet':
        return "DeFiChain Testnet";
      case 'mainnet':
        return "DeFiChain Mainnet";
      default:
        return "DeFi-Meta-Chain Testnet";
    }
  }

  @override
  Widget build(BuildContext context) {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    String networkType = getNetworkType();

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
                Image.asset(
                  'assets/connection.gif',
                  height: 32,
                  width: 32,
                ),
                SizedBox(
                  width: 16,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Jelly speaks more than one language!",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    "Select the network you want to use",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ])
              ],
            ),
            content: Builder(
              builder: (context) {
                var width = widget.isFullSize
                    ? MediaQuery.of(context).size.width * 0.5
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
                        children: [
                          ListEntry(
                            iconUrl: 'assets/tokens/bitcoin.svg',
                            label: 'Bitcoin Mainnet',
                            callback: () async {
                              Navigator.of(context).pop();
                              SettingsHelper.settings.isBitcoin = true;
                              SettingsHelper.settings.network = 'mainnet';
                              await accountCubit.changeNetwork(
                                  SettingsHelper.settings.network!);
                              await settingsHelper.saveSettings();
                            },
                          ),
                          Divider(
                            height: 0,
                            color: Theme.of(context).dividerColor,
                          ),
                          ListEntry(
                            iconUrl: 'assets/tokens/bitcoin.svg',
                            label: 'Bitcoin Testnet',
                            callback: () async {
                              Navigator.of(context).pop();
                              SettingsHelper.settings.isBitcoin = true;
                              SettingsHelper.settings.network = 'testnet';
                              await accountCubit.changeNetwork(
                                  SettingsHelper.settings.network!);
                              await settingsHelper.saveSettings();
                            },
                          ),
                          Divider(
                            height: 0,
                            color: Theme.of(context).dividerColor,
                          ),
                          ListEntry(
                            iconUrl: 'assets/tokens/defi.svg',
                            label: 'DeFiChain Mainnet',
                            callback: () async {
                              Navigator.of(context).pop();
                              SettingsHelper.settings.network = 'mainnet';
                              SettingsHelper.settings.isBitcoin = false;
                              await accountCubit.changeNetwork(
                                  SettingsHelper.settings.network!);
                              await settingsHelper.saveSettings();
                            },
                          ),
                          Divider(
                            height: 0,
                            color: Theme.of(context).dividerColor,
                          ),
                          ListEntry(
                            iconUrl: 'assets/tokens/defi.svg',
                            label: 'DeFiChain Testnet',
                            callback: () async {
                              Navigator.of(context).pop();
                              SettingsHelper.settings.network = 'testnet';
                              SettingsHelper.settings.isBitcoin = false;
                              await accountCubit.changeNetwork(
                                  SettingsHelper.settings.network!);
                              await settingsHelper.saveSettings();
                            },
                          ),
                          Divider(
                            height: 0,
                            color: Theme.of(context).dividerColor,
                          ),
                          ListEntry(
                            iconUrl: 'assets/tokens/defi_blue.svg',
                            label: 'DeFi-Meta-Chain Testnet',
                            callback: () {
                              print(4);
                            },
                            disabled: true,
                          ),
                        ],
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

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showMyDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  networkType,
                  style: Theme.of(context).textTheme.headline4,
                )
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
