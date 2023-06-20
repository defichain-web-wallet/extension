import 'dart:convert';

import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'address_book_state.dart';

class AddressBookCubit extends Cubit<AddressBookState> {
  AddressBookCubit() : super(AddressBookState());

  NetworkTypeModel? getNetworkType(context, String address){
    NetworkTypeModel? networkTypeModel;
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    final networks = walletCubit.state.applicationModel!.networks;
    networks.forEach((element) {
      if(element.checkAddress(address)){
        networkTypeModel = element.networkType;
      }
    });
    return networkTypeModel;
  }

  addAddress(context, AddressBookModel addressBook) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var currentNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    addressBook.network = currentNetwork.networkType;
    account.addToAddressBook(addressBook);

    StorageService.saveApplication(walletCubit.state.applicationModel!);

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      addressBookList: account.addressBook,
    ));
  }

  addAddressToLastSent(context, AddressBookModel addressModel) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var currentNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    addressModel.network = currentNetwork.networkType;
    account.addToLastSend(addressModel);

    StorageService.saveApplication(walletCubit.state.applicationModel!);

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      lastSentList: account.lastSendList,
    ));
  }

  removeAddressFromLastSent(context, AddressBookModel addressModel) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    account.removeFromLastSend(addressModel);

    StorageService.saveApplication(walletCubit.state.applicationModel!);

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      lastSentList: account.lastSendList,
    ));
  }
  deleteAddress(context, AddressBookModel addressBook) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    account.removeFromAddressBook(addressBook);

    StorageService.saveApplication(walletCubit.state.applicationModel!);

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      addressBookList: account.addressBook,
    ));
  }

  editAddress(context, AddressBookModel addressBook) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    account.editAddressBook(addressBook);

    StorageService.saveApplication(walletCubit.state.applicationModel!);

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      addressBookList: account.addressBook,
    ));
  }


  init(context, {bool currentNetowk = false}) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
    ));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var network = walletCubit.state.applicationModel!.activeNetwork!;
    late List<AddressBookModel> addressBook;
    late List<AddressBookModel> lastSend;
    if(currentNetowk){
      addressBook = account.addressBook.where((element) => element.network!.networkName.name == network.networkType.networkName.name).toList();
      lastSend = account.lastSendList.where((element) => element.network!.networkName.name == network.networkType.networkName.name).toList();
    } else {
      addressBook = account.addressBook;
      lastSend = account.lastSendList;
    }
    emit(state.copyWith(
      status: AddressBookStatusList.success,
      addressBookList: account.addressBook,
      lastSentList: account.lastSendList,
    ));
  }
}
