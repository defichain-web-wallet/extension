import 'dart:ui';

import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/address_book/delete_contact_dialog.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/address_book/contact_tile.dart';
import 'package:defi_wallet/widgets/address_book/create_edit_contact_dialog.dart';
import 'package:defi_wallet/widgets/address_book/last_sent_tile.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/create_edit_account/create_edit_account_dialog.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field_new.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../widgets/fields/custom_text_form_field.dart';

class AddressBookScreenNew extends StatefulWidget {
  const AddressBookScreenNew({Key? key}) : super(key: key);

  @override
  State<AddressBookScreenNew> createState() => _AddressBookScreenNewState();
}

class _AddressBookScreenNewState extends State<AddressBookScreenNew> {
  TextEditingController controller = TextEditingController();
  bool isSelectedContacts = true;
  bool isSelectedLastSent = false;
  bool isDeleted = false;


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
          body: Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.only(
              top: 22,
              bottom: 0,
              left: 16,
              right: 0,
            ),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Address Book',
                                style: headline3,
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      barrierColor: Color(0x0f180245),
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CreateEditContactDialog(
                                          isEdit: false,
                                          confirmCallback: () {
                                            print('confirm');
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.portage.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(Icons.add),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          CustomTextFormField(
                            prefix: Icon(Icons.search),
                            addressController: controller,
                            hintText: 'Name or Contact Address',
                            isBorder: true,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SelectorTabElement(
                                    callback: () {
                                      setState(() {
                                        isSelectedContacts = true;
                                        isSelectedLastSent = false;
                                      });
                                    },
                                    title: 'Contacts',
                                    isSelect: isSelectedContacts,
                                  ),
                                  SizedBox(
                                    width: 24,
                                  ),
                                  SelectorTabElement(
                                    callback: () {
                                      setState(() {
                                        isSelectedContacts = false;
                                        isSelectedLastSent = true;
                                      });
                                    },
                                    isSelect: isSelectedLastSent,
                                    title: 'Last sent',
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/setting.svg', color: AppColors.darkTextColor,),
                                  SizedBox(
                                    width: 4,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 9,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: 12,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  if (isSelectedContacts)
                                    ContactTile(
                                      contactName: 'Kate Kh[${index}]',
                                      contactAddress:
                                          '[${index}]193767erut646ee23e3h3urtr3',
                                      networkName: 'DeFiChain Mainnet',
                                      editCallback: () {
                                        showDialog(
                                          barrierColor: Color(0x0f180245),
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CreateEditContactDialog(
                                              contactName: 'Kate Kh[${index}]',
                                              address:
                                                  '[${index}]193767erut646ee23e3h3urtr3',
                                              isEdit: true,
                                              confirmCallback: () {
                                                print('edit');
                                              },
                                              deleteCallback: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                  barrierColor:
                                                      Color(0x0f180245),
                                                  barrierDismissible: true,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return DeleteContactDialog(
                                                      confirmCallback: () {},
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  if (isSelectedLastSent) LastSentTile(
                                    address: 'df1q3lyukeychd55pt2u3xknnuxqzwuhdasgvwuuhc',
                                  ),
                                  Divider(
                                    height: 1,
                                    color: AppColors.lavenderPurple
                                        .withOpacity(0.16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (isDeleted)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 223,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.4),
                            color: AppColors.malachite.withOpacity(0.08),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.4),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
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
                                  Text(
                                    'Contact has been deleted',
                                    style: headline5.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
