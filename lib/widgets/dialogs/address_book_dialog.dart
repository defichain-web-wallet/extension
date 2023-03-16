import 'dart:ui';

import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/mixins/network_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/address_book/contact_tile.dart';
import 'package:defi_wallet/widgets/address_book/last_sent_tile.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:defi_wallet/widgets/status_logo_and_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AddressBookDialog extends StatefulWidget {
  final Function(AddressBookModel contact)? getContact;
  final Function(String address)? getAddress;

  const AddressBookDialog({
    Key? key,
    this.getContact,
    this.getAddress,
  }) : super(key: key);

  @override
  State<AddressBookDialog> createState() => _AddressBookDialogState();
}

class _AddressBookDialogState extends State<AddressBookDialog>
    with ThemeMixin, NetworkMixin {
  int iterator = 0;
  TextEditingController controller = TextEditingController();
  List<AddressBookModel>? viewList = [];
  List<AddressBookModel>? allContactsList = [];
  List<AddressBookModel>? lastSent = [];
  bool isSelectedContacts = true;
  bool isSelectedLastSent = false;

  @override
  Widget build(BuildContext context) {
    AddressBookCubit addressBookCubit =
        BlocProvider.of<AddressBookCubit>(context);
    if (iterator == 0) {
      iterator++;

      addressBookCubit.loadAddressBook();
    }
    return BlocBuilder<AddressBookCubit, AddressBookState>(
      builder: (context, addressBookState) {
        if (iterator == 1 &&
            addressBookState.status == AddressBookStatusList.success) {
          allContactsList = addressBookState.addressBookList;
          allContactsList!.forEach((element) {
            if (element.network == currentNetworkName()) {
              viewList!.add(element);
            }
          });
          lastSent = addressBookState.lastSentList;
          iterator++;
        }
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: AlertDialog(
            insetPadding: EdgeInsets.all(24),
            contentPadding: EdgeInsets.zero,
            backgroundColor: isDarkTheme()
                ? DarkColors.drawerBgColor
                : LightColors.drawerBgColor,
            shape: RoundedRectangleBorder(
              side: isDarkTheme()
                  ? BorderSide(color: DarkColors.drawerBorderColor)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              width: 312,
              height: 552,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: isDarkTheme()
                    ? DarkColors.drawerBgColor
                    : LightColors.drawerBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                      bottom: 0,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Address Book',
                                    style: headline3,
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
                                onChanged: (value) {
                                  setState(() {
                                    if (addressBookState.addressBookList !=
                                        null) {
                                      List<AddressBookModel>? list = [];
                                      addressBookState.addressBookList!
                                          .forEach((element) {
                                        if (element.name!
                                                .toLowerCase()
                                                .contains(
                                                    value.toLowerCase()) ||
                                            element.address!.contains(value)) {
                                          list.add(element);
                                        }
                                      });
                                      viewList = list;
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                ],
                              ),
                              SizedBox(
                                height: 9,
                              ),
                            ],
                          ),
                        ),
                        if (isSelectedContacts)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: (viewList != null && viewList!.isNotEmpty)
                                  ? ListView.builder(
                                      itemCount: viewList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (widget.getContact !=
                                                      null) {
                                                    widget.getContact!(
                                                        viewList![index]);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: ContactTile(
                                                    index: 0,
                                                    isDialog: true,
                                                    contactName:
                                                        viewList![index].name!,
                                                    contactAddress:
                                                        viewList![index]
                                                            .address!,
                                                    networkName:
                                                        viewList![index]
                                                            .network!,
                                                  ),
                                                ),
                                              ),
                                              if (!(viewList!.length ==
                                                  index + 1))
                                                Divider(
                                                  height: 1,
                                                  color: AppColors
                                                      .lavenderPurple
                                                      .withOpacity(0.16),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: StatusLogoAndTitle(
                                        subtitle:
                                            'Jelly can\'t see any contacts in your address book',
                                        isTitlePosBefore: true,
                                      ),
                                    ),
                            ),
                          ),
                        if (isSelectedLastSent)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: (lastSent != null && lastSent!.isNotEmpty)
                                  ? ListView.builder(
                                      itemCount: lastSent!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (widget.getAddress !=
                                                      null) {
                                                    widget.getAddress!(
                                                        lastSent![index]
                                                            .address!);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: LastSentTile(
                                                    address: lastSent![index]
                                                        .address!,
                                                    index: index,
                                                  ),
                                                ),
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
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: StatusLogoAndTitle(
                                        subtitle:
                                            'You don\'t have addresses yet',
                                        isTitlePosBefore: true,
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, right: 16),
                    child: Row(
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
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
