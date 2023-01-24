import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/mixins/netwrok_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/address_book/create_edit_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LastSentTile extends StatefulWidget {
  final String address;
  final int index;

  const LastSentTile({
    Key? key,
    required this.address,
    required this.index,
  }) : super(key: key);

  @override
  State<LastSentTile> createState() => _LastSentTileState();
}

class _LastSentTileState extends State<LastSentTile> with NetworkMixin {
  cutAddress(String s) {
    return s.substring(0, 14) + '...' + s.substring(28, 42);
  }

  @override
  Widget build(BuildContext context) {
    AddressBookCubit addressBookCubit =
      BlocProvider.of<AddressBookCubit>(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 12.8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              cutAddress(widget.address),
              style: headline5.copyWith(
                fontSize: 13,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    barrierColor: Color(0x0f180245),
                    barrierDismissible: false,
                    context: context,
                    builder:
                        (BuildContext dialogContext) {
                      return CreateEditContactDialog(
                        address: widget.address,
                        isEdit: false,
                        confirmCallback:
                            (name, address) {
                          addressBookCubit.addAddress(
                            AddressBookModel(
                                name: name,
                                address: address,
                                network: currentNetworkName(),
                            ),
                          );
                          Navigator.pop(dialogContext);
                        },
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.darkTextColor.withOpacity(0.5),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    addressBookCubit.removeAddressFromLastSent(widget.index);
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.darkTextColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
