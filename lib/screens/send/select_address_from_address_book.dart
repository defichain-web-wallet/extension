import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/screens/send/send_token_selector.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectAddressFromAddressBook extends StatefulWidget {
  const SelectAddressFromAddressBook({Key? key}) : super(key: key);

  @override
  _SelectAddressFromAddressBookState createState() =>
      _SelectAddressFromAddressBookState();
}

class _SelectAddressFromAddressBookState
    extends State<SelectAddressFromAddressBook> {
  TextEditingController searchController = TextEditingController();
  bool isPinkIcon = false;
  final List<AddressBookModel> _filterList = [];
  String searchValue = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBookCubit, AddressBookState>(
        builder: (context, addressBookState) {
      AddressBookCubit addressBookCubit =
          BlocProvider.of<AddressBookCubit>(context);
      addressBookCubit.loadAddressBook();
      return ScaffoldConstrainedBoxNew(
        appBar: MainAppBar(
          title: "Select address from Address book",
          // action: Container(),
        ),
        child: Column(
          children: [
            Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Focus(
                onFocusChange: (focused) {
                  setState(() {
                    isPinkIcon = focused;
                  });
                },
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  style: Theme.of(context).textTheme.button,
                  decoration: InputDecoration(
                    hintText: 'Search address',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    hoverColor:
                        Theme.of(context).inputDecorationTheme.hoverColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .textTheme
                              .button!
                              .decorationColor!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.pinkColor),
                    ),
                    prefixIcon: Image(
                      image: isPinkIcon
                          ? AssetImage('assets/images/search_pink.png')
                          : AssetImage('assets/images/search_gray.png'),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (addressBookState.addressBookList != null) {
                        searchValue = value;
                        _searchAddress(
                            value, addressBookState.addressBookList!);
                      }
                    });
                  },
                  controller: searchController,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: searchValue != ''
                  ? _filterList.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filterList.length,
                          itemBuilder: (context, index) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              SendTokenSelector(
                                        selectedAddress:
                                            _filterList[index].address!,
                                      ),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.only(
                                      top: 0, bottom: 10, left: 0, right: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 20, left: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _filterList[index].name!,
                                              softWrap: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2,
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              _filterList[index].address!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .apply(
                                                    fontSizeFactor: 0.9,
                                                    fontFamily: 'IBM Plex Sans',
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'No matches found',
                            // style: TextStyle(
                            //   fontSize: 30,
                            // ),
                          ),
                        )
                  : addressBookState.addressBookList != null
                      ? addressBookState.addressBookList!.isNotEmpty
                          ? ListView.builder(
                              itemCount:
                                  addressBookState.addressBookList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              SendTokenSelector(
                                            selectedAddress: addressBookState
                                                .addressBookList![index]
                                                .address!,
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(
                                          top: 0,
                                          bottom: 10,
                                          left: 0,
                                          right: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20, bottom: 20, left: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  addressBookState
                                                      .addressBookList![index]
                                                      .name!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text(
                                                  addressBookState
                                                      .addressBookList![index]
                                                      .address!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4!
                                                      .apply(
                                                        fontSizeFactor: 0.9,
                                                        fontFamily:
                                                            'IBM Plex Sans',
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'Address book is empty',
                                // style: TextStyle(
                                //   fontSize: 30,
                                // ),
                              ),
                            )
                      : Center(
                          child: Text(
                            'Address book is empty',
                            // style: TextStyle(
                            //   fontSize: 30,
                            // ),
                          ),
                        ),
            )
          ],
        ),
      );
    });
  }

  _searchAddress(String value, List<AddressBookModel> notFilterList) {
    _filterList.clear();
    for (int i = 0; i < notFilterList.length; i++) {
      var item = notFilterList[i];

      if (item.name!.toLowerCase().contains(value.toLowerCase())) {
        _filterList.add(item);
      }
    }
  }
}
