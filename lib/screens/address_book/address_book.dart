import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/screens/address_book/add_new_address.dart';
import 'package:defi_wallet/screens/address_book/widgets/address_book_buttons.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({Key? key}) : super(key: key);

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBookCubit, AddressBookState>(
        builder: (context, addressBookState) {
          AddressBookCubit addressBookCubit =
          BlocProvider.of<AddressBookCubit>(context);
          addressBookCubit.loadAddressBook();

          return ScaffoldConstrainedBoxNew(
            appBar: MainAppBar(
              title: 'Address book',
              action: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  iconSize: 20,
                  splashRadius: 18,
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            AddNewAddress(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ),
            ),
            child: addressBookState.addressBookList != null
                ? addressBookState.addressBookList!.isNotEmpty
                ? ListView.builder(
              itemCount: addressBookState.addressBookList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.only(
                      top: 0, bottom: 10, left: 0, right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 250,
                              child: Text(
                                addressBookState
                                    .addressBookList![index].name!,
                                style:
                                Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              addressBookState
                                  .addressBookList![index].address!,
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
                      Column(
                        children: [
                          AddressBookButtons(
                            editCallback: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                      AddNewAddress(
                                        name: addressBookState
                                            .addressBookList![index].name!,
                                        address: addressBookState
                                            .addressBookList![index].address!,
                                        id: addressBookState
                                            .addressBookList![index].id,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration:
                                  Duration.zero,
                                ),
                              );
                            },
                            deleteCallback: () {
                              setState(() {
                                addressBookCubit.deleteAddress(
                                    addressBookState
                                        .addressBookList![index]);
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            )
                : Center(
              child: Text(
                'Address book is empty',
              ),
            )
                : Center(
              child: Text(
                'Address book is empty',
              ),
            ),
          );
        });
  }
}
