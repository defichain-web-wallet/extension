import 'package:defi_wallet/widgets/buttons/account_menu_button.dart';
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
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(colors: [
                                        AppColors.redViolet.withOpacity(0.16),
                                        AppColors.razzmatazz.withOpacity(0.16),
                                      ]),
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
                                          style: headline6.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        SvgPicture.asset(
                                            'assets/icons/edit_gradient.svg'),
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
                                              backgroundColor: AppColors.portage
                                                  .withOpacity(0.16),
                                              child: Text(
                                                'J',
                                                style: headline4.copyWith(
                                                    fontSize: 11,
                                                    color: AppColors.portage),
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
                                  Divider(
                                    height: 28,
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.05),
                                    thickness: 1,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 11,
                                      ),
                                      Text(
                                        'Create new account',
                                        style: headline5,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 14,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    AccountMenuButton(
                      callback: () {},
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
                      callback: () {},
                      iconPath: 'assets/icons/night_mode.svg',
                      title: 'Night Mode',
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    AccountMenuButton(
                      callback: () {
                        setState(() {
                          isDarkTheme = !isDarkTheme;
                        });
                      },
                      isStaticBg: true,
                      iconPath: 'assets/icons/jelly_theme_explore.svg',
                      title: 'Explore Jelly themes',
                      afterTitleWidget: DefiSwitch(
                        isEnable: isDarkTheme,
                      ),
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
                      callback: () {},
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
    );
  }
}
