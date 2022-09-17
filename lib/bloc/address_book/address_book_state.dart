part of 'address_book_cubit.dart';

enum AddressBookStatusList { initial, loading, success, restore, failure }

class AddressBookState extends Equatable {
  final AddressBookStatusList status;
  final List<AddressBookModel>? addressBookList;

  AddressBookState({
    this.status = AddressBookStatusList.initial,
    this.addressBookList,
  });

  @override
  List<Object?> get props => [
    status,
    addressBookList,
  ];

  AddressBookState copyWith({
    AddressBookStatusList? status,
    List<AddressBookModel>? addressBookList,
  }) {
    return AddressBookState(
      status: status ?? this.status,
      addressBookList: addressBookList ?? this.addressBookList,
    );
  }
}
