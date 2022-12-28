import 'dart:async';
import 'dart:ui';

import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SendSummaryScreen extends StatefulWidget {
  final Function()? callback;
  final AddressBookModel? contact;
  final String? address;
  final TokensModel token;
  final double amount;
  final bool isAfterAddContact;

  const SendSummaryScreen({
    Key? key,
    required this.token,
    required this.amount,
    this.callback,
    this.contact,
    this.address,
    this.isAfterAddContact = false,
  }) : super(key: key);

  @override
  State<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends State<SendSummaryScreen> with ThemeMixin {
  String titleText = 'Summary';
  bool isShowAdded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isAfterAddContact) {
      isShowAdded = true;
      Timer(Duration(milliseconds: 1500), () {
        setState(() {
          isShowAdded = false;
        });
      });
    }
  }

  cutAddress(String s) {
    return s.substring(0, 14) + '...' + s.substring(28, 42);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          drawerScrimColor: Color(0x0f180245),
          endDrawer: AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: NewMainAppBar(
            isShowLogo: false,
          ),
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 24,
                  left: 16,
                  right: 16,
                ),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.scaffoldContainerBgColor
                      : LightColors.scaffoldContainerBgColor,
                  border: isDarkTheme()
                      ? Border.all(
                          width: 1.0,
                          color: Colors.white.withOpacity(0.05),
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: StretchBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  titleText,
                                  style: headline2.copyWith(
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 21),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.lavenderPurple
                                          .withOpacity(0.32))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Do you really want to send',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .color!
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        TokensHelper().getImageNameByTokenName(
                                            widget.token.symbol),
                                      ),
                                      SizedBox(
                                        width: 6.4,
                                      ),
                                      Text(
                                        widget.amount.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .copyWith(
                                              fontSize: 20,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    'to',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .color!
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  if (widget.contact != null)
                                    Text(
                                      widget.contact!.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                            fontSize: 20,
                                          ),
                                    ),
                                  if (widget.contact != null)
                                    SizedBox(
                                      height: 4,
                                    ),
                                  if (widget.contact != null)
                                    Text(
                                      widget.contact!.address!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline6!
                                                .color!
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  if (widget.address != null)
                                    Tooltip(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkTheme()
                                            ? DarkColors.drawerBgColor
                                            : LightColors.drawerBgColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.whiteLilac,
                                        ),
                                      ),
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .color!
                                                .withOpacity(0.5),
                                            fontSize: 10,
                                          ),
                                      message: '${widget.address!}',
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          cutAddress(widget.address!),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                fontSize: 20,
                                              ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            NewPrimaryButton(
                              width: buttonSmallWidth,
                              callback: () {},
                              title: 'Continue',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isShowAdded)
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 253,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.4),
                            color: AppColors.malachite.withOpacity(0.08),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.4),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.done,
                                    color: Color(0xFF00CF21),
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('A new contact has been added')
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 96,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
