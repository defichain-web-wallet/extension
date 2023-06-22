import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/mixins/network_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/dialogs/create_edit_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LastSentTile extends StatefulWidget {
  final AddressBookModel address;
  final int index;

  const LastSentTile({
    Key? key,
    required this.address,
    required this.index,
  }) : super(key: key);

  @override
  State<LastSentTile> createState() => _LastSentTileState();
}

class _LastSentTileState extends State<LastSentTile> with NetworkMixin, ThemeMixin {
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
              cutAddress(widget.address.address!),
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
                    barrierColor: AppColors.tolopea.withOpacity(0.06),
                    barrierDismissible: false,
                    context: context,
                    builder:
                        (BuildContext dialogContext) {
                      return CreateEditContactDialog(
                        address: widget.address.address!,
                        isEdit: false,
                        confirmCallback:
                            (name, address, network) {
                          addressBookCubit.addAddress(context,
                            AddressBookModel(
                                name: name,
                                address: address,
                                network: network,
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
                  color: isDarkTheme() ? AppColors.white.withOpacity(0.5) : AppColors.darkTextColor.withOpacity(0.5),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    addressBookCubit.removeAddressFromLastSent(context, widget.address);
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDarkTheme() ? AppColors.white.withOpacity(0.5) : AppColors.darkTextColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
