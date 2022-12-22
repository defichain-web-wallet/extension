import 'dart:ui';

import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/screens/address_book/address_book_screen_new.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/utils/theme/theme_manager.dart';
import 'package:defi_wallet/widgets/buttons/account_menu_button.dart';
import 'package:defi_wallet/widgets/create_edit_account/create_edit_account_dialog.dart';
import 'package:defi_wallet/widgets/defi_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:defi_wallet/utils/theme/theme.dart';

class AccountDrawer extends StatefulWidget {
  final double? width;

  const AccountDrawer({
    Key? key,
    this.width = 304,
  }) : super(key: key);

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  LockHelper lockHelper = LockHelper();
  bool isDarkTheme = false;

  void lockWallet() async {
    await lockHelper.lockWallet();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>  LockScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: Drawer(
        width: widget.width! + 16,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: AppColors.whiteLilac2,
                )),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
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
                                  Container(
                                    width: 16,
                                    height: 16,
                                    child: IconButton(
                                      splashRadius: 12,
                                      padding: const EdgeInsets.all(0),
                                      onPressed: () =>
                                          Scaffold.of(context).closeEndDrawer(),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.redViolet
                                                    .withOpacity(0.16),
                                                AppColors.razzmatazz
                                                    .withOpacity(0.16),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: GradientText(
                                              'K',
                                              style: headline6.copyWith(
                                                  fontWeight: FontWeight.w700),
                                              gradientType: GradientType.linear,
                                              gradientDirection:
                                                  GradientDirection.btt,
                                              colors: [
                                                AppColors.electricViolet,
                                                AppColors.hollywoodCerise,
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Katheryna Khachaturova',
                                                style: Theme.of(context).textTheme.headline6!.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0),
                                                  icon: SvgPicture.asset(
                                                    'assets/icons/edit_gradient.svg',
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      barrierColor:
                                                          Color(0x0f180245),
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CreateEditAccountDialog(
                                                          isEdit: true,
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 28,
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.05),
                                          thickness: 1,
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: AppColors
                                                        .portage
                                                        .withOpacity(0.16),
                                                    child: Text(
                                                      'J',
                                                      style: headline4.copyWith(
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .portage),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 6.4,
                                                  ),
                                                  Text(
                                                    'Jelly Fishy',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Divider(
                                          height: 1,
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.05),
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  AccountMenuButton(
                                    callback: () {
                                      showDialog(
                                        barrierColor: Color(0x0f180245),
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CreateEditAccountDialog();
                                        },
                                      );
                                    },
                                    isHoverBackgroundEffect: false,
                                    iconPath: 'assets/icons/add.svg',
                                    title: 'Create new account',
                                  ),
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
                        callback: () {
                          Scaffold.of(context).closeEndDrawer();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  AddressBookScreenNew(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        iconPath: 'assets/icons/address_book.svg',
                        title: 'Address Book',
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      AccountMenuButton(
                        callback: () {},
                        iconPath: 'assets/icons/setting.svg',
                        title: 'Settings',
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      AccountMenuButton(
                        callback: () {},
                        iconPath: 'assets/icons/ledger.svg',
                        title: 'Ledger',
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      AccountMenuButton(
                        callback: () {
                          setState(() {
                            isDarkTheme = !isDarkTheme;
                          });
                          ThemeManager.changeTheme(context);
                        },
                        iconPath: 'assets/icons/night_mode.svg',
                        title: 'Night Mode',
                        afterTitleWidget: DefiSwitch(
                          isEnable: isDarkTheme,
                          onToggle: (bool value) {
                            setState(() {
                              isDarkTheme = value;
                            });
                            ThemeManager.changeTheme(context);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      AccountMenuButton(
                        isStaticBg: true,
                        callback: () {

                        },
                        iconPath: 'assets/icons/jelly_theme_explore.svg',
                        title: 'Explore Jelly themes',
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Divider(
                        height: 8,
                        color: Theme.of(context).dividerColor.withOpacity(0.05),
                        thickness: 1,
                      ),
                      AccountMenuButton(
                        // isStaticBg: true,
                        callback: () {
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
  }
}
