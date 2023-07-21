import 'dart:ui';

import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/ledger_account_model.dart';
import 'package:defi_wallet/screens/address_book/address_book_screen_new.dart';
import 'package:defi_wallet/screens/ledger/guide/connect_ledger_overlay_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/settings/setting_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme_manager.dart';
import 'package:defi_wallet/widgets/account_drawer/selected_account.dart';
import 'package:defi_wallet/widgets/buttons/account_menu_button.dart';
import 'package:defi_wallet/widgets/dialogs/create_edit_account_dialog.dart';
import 'package:defi_wallet/widgets/defi_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/utils/theme/theme.dart';

class AccountDrawer extends StatefulWidget {
  final double? width;

  const AccountDrawer({
    Key? key,
    this.width = 280,
  }) : super(key: key);

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> with ThemeMixin {
  LockHelper lockHelper = LockHelper();
  late double accountsSelectorHeight;

  void lockWallet() async {
    await lockHelper.lockWallet();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LockScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (prev, current) => true,
      builder: (BuildContext context, state) {
        WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
        var accounts = state.accounts;
        if (accounts.length == 1) {
          accountsSelectorHeight = 245;
        } else if (accounts.length == 2) {
          accountsSelectorHeight = 280;
        } else {
          accountsSelectorHeight = 320;
        }
        return BackdropFilter(
          filter: isLargeScreen(context)
              ? ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0)
              : ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: Drawer(
            width: widget.width!,
            backgroundColor: Colors.transparent,
            elevation: isLargeScreen(context) ? 0 : 3,
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen(context) ? 0 : 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.drawerBgColor
                      : LightColors.drawerBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 1,
                    color: isDarkTheme()
                        ? DarkColors.drawerBorderColor
                        : LightColors.drawerBorderColor,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: accountsSelectorHeight,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .selectedRowColor
                                  .withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 11,
                                    top: 11,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!isLargeScreen(context))
                                        Container(
                                          width: 16,
                                          height: 16,
                                          child: IconButton(
                                            splashRadius: 12,
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () =>
                                                Scaffold.of(context)
                                                    .closeEndDrawer(),
                                            icon: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .dividerColor
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SelectedAccount(
                                        accountName: state.activeAccount.name,
                                        onEdit: () {
                                          showDialog(
                                            barrierColor: AppColors.tolopea
                                                .withOpacity(0.06),
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CreateEditAccountDialog(
                                                callback: (s) {
                                                  setState(() {
                                                    walletCubit.editAccount(
                                                        s,
                                                        state
                                                            .activeAccount.id!);
                                                  });
                                                },
                                                name: state.activeAccount.name,
                                                isEdit: true,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: ScrollConfiguration(
                                          behavior:
                                              ScrollConfiguration.of(context)
                                                  .copyWith(scrollbars: false),
                                          child: ListView.builder(
                                            itemCount: accounts.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  Divider(
                                                    height: 1,
                                                    endIndent: 12,
                                                    indent: 12,
                                                    color: Theme.of(context)
                                                        .dividerColor
                                                        .withOpacity(0.05),
                                                    thickness: 1,
                                                  ),
                                                  AccountMenuButton(
                                                      accountSelectMode: true,
                                                      account: accounts[index],
                                                      callback: accounts[
                                                                      index]
                                                                  .id ==
                                                              state
                                                                  .activeAccount
                                                                  .id
                                                          ? null
                                                          : (accountIndex) async {
                                                              walletCubit
                                                                  .updateActiveAccount(
                                                                      accounts[
                                                                              index]
                                                                          .id!);
                                                              Scaffold.of(
                                                                      context)
                                                                  .closeEndDrawer();
                                                            },
                                                      isHoverBackgroundEffect:
                                                          false,
                                                      iconPath:
                                                          'assets/icons/add.svg',
                                                      title:
                                                          accounts[index].name),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Divider(
                                            height: 1,
                                            endIndent: 12,
                                            indent: 12,
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.05),
                                            thickness: 1,
                                          ),
                                          AccountMenuButton(
                                            callback: (index) {
                                              showDialog(
                                                barrierColor: AppColors.tolopea
                                                    .withOpacity(0.06),
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CreateEditAccountDialog(
                                                    callback: (s) async {
                                                      await walletCubit
                                                          .addNewAccount(s);
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            isHoverBackgroundEffect: false,
                                            iconPath: 'assets/icons/add.svg',
                                            title: 'Create new account',
                                          ),
                                          AccountMenuButton(
                                            callback: (index) {
                                              showDialog(
                                                barrierColor: AppColors.tolopea
                                                    .withOpacity(0.06),
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ConnectLedgerOverlayScreen(
                                                      appName: "test");
                                                  // return CreateEditAccountDialog(
                                                  //   callback: (s) async {
                                                  //     await walletCubit
                                                  //         .addNewAccount(s);
                                                  //   },
                                                  // );
                                                },
                                              );
                                            },
                                            isHoverBackgroundEffect: false,
                                            iconPath: 'assets/icons/add.svg',
                                            title: 'Add ledger account',
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          AccountMenuButton(
                            callback: (index) {
                              Scaffold.of(context).closeEndDrawer();
                              NavigatorService.push(
                                context,
                                AddressBookScreenNew(),
                              );
                            },
                            iconPath: 'assets/icons/address_book.svg',
                            title: 'Address Book',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            callback: (index) {
                              Scaffold.of(context).closeEndDrawer();
                              NavigatorService.push(
                                context,
                                SettingScreen(),
                              );
                            },
                            iconPath: 'assets/icons/setting.svg',
                            title: 'Settings',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            callback: (index) {},
                            iconPath: 'assets/icons/ledger.svg',
                            title: 'Ledger',
                            isFuture: true,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            isTheme: true,
                            callback: (index) {
                              ThemeManager.changeTheme(context);
                            },
                            iconPath: isDarkTheme()
                                ? 'assets/icons/light_mode.svg'
                                : 'assets/icons/night_mode.svg',
                            hoverBgColor: isDarkTheme()
                                ? AppColors.white
                                : AppColors.blackRock,
                            hoverTextColor: isDarkTheme()
                                ? AppColors.blackRock
                                : AppColors.white,
                            title: 'Night Mode',
                            afterTitleWidget: DefiSwitch(
                              isEnable: isDarkTheme(),
                              onToggle: (bool value) {
                                ThemeManager.changeTheme(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            isStaticBg: true,
                            callback: (index) {},
                            iconPath: 'assets/icons/jelly_theme_explore.svg',
                            title: 'Explore Jelly themes',
                            isFuture: true,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Divider(
                            height: 8,
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.05),
                            thickness: 1,
                          ),
                          AccountMenuButton(
                            isLockType: true,
                            callback: (index) {
                              lockWallet();
                            },
                            iconPath: 'assets/icons/lock.svg',
                            title: 'Lock Wallet',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
