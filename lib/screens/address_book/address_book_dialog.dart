import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/address_book/contact_tile.dart';
import 'package:defi_wallet/widgets/address_book/last_sent_tile.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AddressBookDialog extends StatefulWidget {
  final Function(AddressBookModel contact)? getContact;

  const AddressBookDialog({
    Key? key,
    this.getContact,
  }) : super(key: key);

  @override
  State<AddressBookDialog> createState() => _AddressBookDialogState();
}

class _AddressBookDialogState extends State<AddressBookDialog> with ThemeMixin {
  int iterator = 0;
  TextEditingController controller = TextEditingController();
  List<AddressBookModel>? viewList = [];
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
          viewList = addressBookState.addressBookList;
          iterator++;
        }

        return AlertDialog(
          insetPadding: EdgeInsets.all(24),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 312,
            height: 552,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isDarkTheme()
                  ? DarkColors.scaffoldContainerBgColor
                  : LightColors.scaffoldContainerBgColor,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                print(addressBookState.addressBookList!.length);
                                setState(() {
                                  if (addressBookState.addressBookList !=
                                      null) {
                                    List<AddressBookModel>? list = [];
                                    addressBookState.addressBookList!
                                        .forEach((element) {
                                      if (element.name!.contains(value) ||
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
                                    SvgPicture.asset(
                                      'assets/icons/filter_icon.svg',
                                      color: AppColors.darkTextColor,
                                    ),
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
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (widget.getContact !=
                                                      null) {
                                                    widget.getContact!(
                                                        viewList![index]);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: ContactTile(
                                                  isDialog: true,
                                                  contactName:
                                                      viewList![index].name!,
                                                  contactAddress:
                                                      viewList![index].address!,
                                                  networkName:
                                                      viewList![index].network!,
                                                ),
                                              ),
                                            ),
                                            if (!(viewList!.length ==
                                                index + 1))
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
                                : Center(
                                    child: Text(
                                      'Oops!',
                                    ),
                                  ),
                          ),
                        ),
                      if (isSelectedLastSent)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            child: (true)
                                ? ListView.builder(
                                    itemCount: 12,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: Column(
                                          children: [
                                            LastSentTile(
                                              address:
                                                  'df1q3lyukeychd55pt2u3xknnuxqzwuhdasgvwuuhc',
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
                                : Center(
                                    child: Text(
                                      'Oops!',
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
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.5),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
