import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/address_book/contact_tile.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field_new.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 54,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.only(
              top: 22,
              bottom: 0,
              left: 16,
              right: 16,
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
                          print('add');
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.portage.withOpacity(0.15),
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
                        SvgPicture.asset('assets/icons/setting.svg'),
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
                if (isSelectedContacts)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: 2,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              ContactTile(
                                contactName: 'Kate Kh',
                                contactAddress: '193767erut646ee23e3h3urtr3',
                                networkName: 'DeFiChain Mainnet',
                                editCallback: () {
                                  print('ww');
                                },
                              ),
                              Divider(
                                height: 1,
                                color:
                                    AppColors.lavenderPurple.withOpacity(0.16),
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
        );
      },
    );
  }
}
