import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/client/hive_names.dart';
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

    var box = await Hive.openBox(HiveBoxes.client);
    // TODO(eth): Refactor the address book so that each address has a key "networkType"
    if (SettingsHelper.isBitcoin()) {
      await box.put(HiveNames.btcAddressBook, jsonString);
    } else {
      await box.put(HiveNames.defiAddressBook, jsonString);
    }
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
      lastSentList: state.lastSentList,
    ));
  }

  addAddressToLastSent(AddressBookModel addressModel) async {
    List<AddressBookModel>? lastSentList;
    final resultJSON = [];
    if (state.lastSentList != null) {
      lastSentList = state.lastSentList!;
      lastSentList.add(addressModel);
    } else {
      lastSentList = [addressModel];
    }

    for (var element in lastSentList) {
      resultJSON.add(element.toJson());
    }

    var jsonString = json.encode(resultJSON);

    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.lastSent, jsonString);

    await box.close();

    emit(state.copyWith(
      lastSentList: lastSentList,
      addressBookList: state.addressBookList,
    ));
  }

  removeAddressFromLastSent(int index) async {
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
      lastSentList: state.lastSentList,
      addressBookList: state.addressBookList,
    ));
    List<AddressBookModel> lastSentList = state.lastSentList!;
    final resultJSON = [];
    lastSentList.removeAt(index);

    for (var element in lastSentList) {
      resultJSON.add(element.toJson());
    }

    var jsonString = json.encode(resultJSON);

    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.lastSent, jsonString);

    await box.close();

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      lastSentList: lastSentList,
      addressBookList: state.addressBookList,
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

    var box = await Hive.openBox(HiveBoxes.client);
    // TODO(eth): View line 35
    if (SettingsHelper.isBitcoin()) {
      await box.put(HiveNames.btcAddressBook, jsonString);
    } else {
      await box.put(HiveNames.defiAddressBook, jsonString);
    }
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
      lastSentList: state.lastSentList,
    ));
  }

  loadAddressBook() async {
    List<AddressBookModel> addressBookList = [];
    List<AddressBookModel> lastSentList = [];
    emit(state.copyWith(
      status: AddressBookStatusList.loading,
      addressBookList: state.addressBookList,
      lastSentList: state.lastSentList,
    ));
    var box = await Hive.openBox(HiveBoxes.client);
    var addressBookJson;
    var lastSentJson;
    // TODO(eth): view line 35
    if (SettingsHelper.isBitcoin()) {
      addressBookJson = await box.get(HiveNames.btcAddressBook);
    } else {
      addressBookJson = await box.get(HiveNames.defiAddressBook);
    }
    lastSentJson = await box.get(HiveNames.lastSent);

    if (addressBookJson != null) {
      List<dynamic> jsonFromString = json.decode(addressBookJson);

      for (var element in jsonFromString) {
        addressBookList.add(AddressBookModel.fromJson(element));
      }
    }

    if (lastSentJson != null) {
      List<dynamic> jsonFromString = json.decode(lastSentJson);

      for (var element in jsonFromString) {
        lastSentList.add(AddressBookModel.fromJson(element));
      }
    }

    await box.close();

    emit(state.copyWith(
      status: AddressBookStatusList.success,
      addressBookList: addressBookList,
      lastSentList: lastSentList,
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

    var box = await Hive.openBox(HiveBoxes.client);
    // TODO(eth): view line 35
    if (SettingsHelper.isBitcoin()) {
      await box.put(HiveNames.btcAddressBook, jsonString);
    } else {
      await box.put(HiveNames.defiAddressBook, jsonString);
    }
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
      lastSentList: state.lastSentList,
    ));
  }

  getLastContact(){
    return state.addressBookList!.last;
  }
}
