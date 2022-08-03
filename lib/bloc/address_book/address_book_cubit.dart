import 'dart:convert';

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
    await box.put('addressBookList', jsonString);
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
    await box.put('addressBookList', jsonString);
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
    ));
  }

  loadAddressBook() async {
    List<AddressBookModel> addressBookList = [];
    var box = await Hive.openBox('AddressBookBox');
    var s = await box.get('addressBookList');

    List<dynamic> jsonFromString = json.decode(s);

    for (var element in jsonFromString) {
      addressBookList.add(AddressBookModel.fromJson(element));
    }

    await box.close();

    emit(state.copyWith(
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
    await box.put('addressBookList', jsonString);
    await box.close();

    emit(state.copyWith(
      addressBookList: addressBookList,
    ));
  }
}
