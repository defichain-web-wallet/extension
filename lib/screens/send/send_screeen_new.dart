import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/address_field_new.dart';
import 'package:defi_wallet/widgets/fields/asset_text_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';

class SendScreenNew extends StatefulWidget {
  const SendScreenNew({Key? key}) : super(key: key);

  @override
  State<SendScreenNew> createState() => _SendScreenNewState();
}

class _SendScreenNewState extends State<SendScreenNew> with ThemeMixin {
  TextEditingController controller = TextEditingController();
  AddressBookModel contact = AddressBookModel();
  String titleText = 'Send';
  String subtitleText = 'Please enter the recipient and amount';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(builder: (
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
        body: Container(
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
                            style:
                                headline2.copyWith(fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            subtitleText,
                            style: Theme.of(context).textTheme.headline5!.apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color!
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24,),
                      AddressFieldNew(
                        controller: controller,
                        contact: contact,
                      ),
                      SizedBox(height: 16,),
                      Row(
                        children: [
                          Text(
                            'Asset',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                      SizedBox(height: 6,),
                      AssetTextField(),
                    ],
                  ),
                  NewPrimaryButton(
                    width: buttonSmallWidth,
                    callback: null,
                    title: 'Continue',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
