import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/address_book/add_new_address.dart';
import 'package:defi_wallet/screens/address_book/widgets/address_book_card.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({Key? key}) : super(key: key);

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  int iterator = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBookCubit, AddressBookState>(
        builder: (context, addressBookState) {
      return ScaffoldConstrainedBox(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < ScreenSizes.medium) {
              return Scaffold(
                appBar: MainAppBar(
                  title: 'Address book',
                  action: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      iconSize: 20,
                      splashRadius: 18,
                      onPressed: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AddNewAddress(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                      icon: Icon(Icons.add),
                    ),
                  ),
                ),
                body: _buildBody(addressBookState),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: Scaffold(
                  appBar: MainAppBar(
                    title: 'Address book',
                    action: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        iconSize: 20,
                        splashRadius: 18,
                        onPressed: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                AddNewAddress(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                        icon: Icon(Icons.add),
                      ),
                    ),
                    isSmall: true,
                  ),
                  body: _buildBody(addressBookState, isFullSize: true),
                ),
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildBody(addressBookState, {isFullSize = false}) {
    AddressBookCubit addressBookCubit =
        BlocProvider.of<AddressBookCubit>(context);
    addressBookCubit.loadAddressBook();
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      padding: const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
      child: Center(
        child: StretchBox(
          child: addressBookState.addressBookList != null
              ? addressBookState.addressBookList!.isNotEmpty
                  ? ListView.builder(
                      itemCount: addressBookState.addressBookList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AddressBookCard(
                          isBorder: isFullSize,
                          name: addressBookState.addressBookList![index].name!,
                          address:
                              addressBookState.addressBookList![index].address!,
                          id: addressBookState.addressBookList![index].id,
                          editCallback: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  AddNewAddress(
                                name: addressBookState
                                    .addressBookList![index].name!,
                                address: addressBookState
                                    .addressBookList![index].address!,
                                id: addressBookState.addressBookList![index].id,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ),
                          deleteCallback: () => setState(() =>
                              addressBookCubit.deleteAddress(
                                  addressBookState.addressBookList![index])),
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
        ),
      ),
    );
  }
}
