import 'dart:convert';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

part 'address_book_state.dart';

class AddressBookCubit extends Cubit<AddressBookState> {
  AddressBookCubit() : super(AddressBookState());

  addAddress(AddressBookModel addressBook) async {
    List<AddressBookModel>? addressBookList;
    final resultJSON = [];
    if (state.addressBookList != null) {
      addressBookList = state.addressBookList!;
      addressBookList.add(addressBook);
    } else {
      addressBookList = [addressBook];
    }

    for (var element in addressBookList) {
      resultJSON.add(element.toJson());
    }

    var jsonString = json.encode(resultJSON);

    var box = await Hive.openBox('AddressBookBox');
    if (SettingsHelper.isBitcoin()) {
      await box.put('btcAddressBookList', jsonString);
    } else {
      await box.put('addressBookList', jsonString);
    }
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
    ));
  }

  editAddress(AddressBookModel addressBook, int id) async {
    List<AddressBookModel>? addressBookList = state.addressBookList;

    for (var i = 0; i < addressBookList!.length; i++) {
      if (addressBookList[i].id == id) {
        addressBookList[i] = addressBook;
      }
    }

    final resultJSON = [];


    for (var element in addressBookList) {
      resultJSON.add(element.toJson());
    }

    var jsonString = json.encode(resultJSON);

    var box = await Hive.openBox('AddressBookBox');
    if (SettingsHelper.isBitcoin()) {
      await box.put('btcAddressBookList', jsonString);
    } else {
      await box.put('addressBookList', jsonString);
    }
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
    ));
  }

  loadAddressBook() async {
    List<AddressBookModel> addressBookList = [];
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
      addressBookList: state.addressBookList,
    ));
    var box = await Hive.openBox('AddressBookBox');
    var addressBookJson;
    if (SettingsHelper.isBitcoin()) {
      addressBookJson = await box.get('btcAddressBookList');
    } else {
      addressBookJson = await box.get('addressBookList');
    }

    if (addressBookJson != null) {
      List<dynamic> jsonFromString = json.decode(addressBookJson);

      for (var element in jsonFromString) {
        addressBookList.add(AddressBookModel.fromJson(element));
      }
    }

    await box.close();

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      addressBookList: addressBookList,
    ));
  }

  deleteAddress(AddressBookModel addressBook) async {
    List<AddressBookModel> addressBookList = state.addressBookList!;

    addressBookList.removeWhere((element) => element.id == addressBook.id);


    final resultJSON = [];


    for (var element in addressBookList) {
      resultJSON.add(element.toJson());
    }

    var jsonString = json.encode(resultJSON);

    var box = await Hive.openBox('AddressBookBox');
    if (SettingsHelper.isBitcoin()) {
      await box.put('btcAddressBookList', jsonString);
    } else {
      await box.put('addressBookList', jsonString);
    }
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
    ));
  }
}
