import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/address_book/address_book_add_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/address_book/address_book_card.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({Key? key}) : super(key: key);

  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  int iterator = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        AddressBookCubit addressBookCubit =
            BlocProvider.of<AddressBookCubit>(context);
        if (iterator == 0) {
          iterator++;
          addressBookCubit.loadAddressBook();
        }
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
                        AddressBookAddScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
                icon: Icon(Icons.add),
              ),
            ),
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: BlocBuilder<AddressBookCubit, AddressBookState>(
            builder: (context, addressBookState) {
              return Container(
                color: Theme.of(context).dialogBackgroundColor,
                padding: AppTheme.screenPadding,
                child: Center(
                  child: StretchBox(
                    child: addressBookState.addressBookList != null
                        ? addressBookState.addressBookList!.isNotEmpty
                            ? ListView.builder(
                                itemCount:
                                    addressBookState.addressBookList!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return AddressBookCard(
                                    name: addressBookState
                                        .addressBookList![index].name!,
                                    address: addressBookState
                                        .addressBookList![index].address!,
                                    id: addressBookState
                                        .addressBookList![index].id,
                                    editCallback: () => Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                AddressBookAddScreen(
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
                                    ),
                                    deleteCallback: () => setState(() =>
                                        addressBookCubit.deleteAddress(
                                            addressBookState
                                                .addressBookList![index])),
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
            },
          ),
        );
      },
    );
  }
}
