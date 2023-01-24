part of 'address_book_cubit.dart';

enum AddressBookStatusList { initial, loading, success, failure }

class AddressBookState extends Equatable {
  final AddressBookStatusList status;
  final List<AddressBookModel>? addressBookList;
  final List<AddressBookModel>? lastSentList;

  AddressBookState({
    this.status = AddressBookStatusList.initial,
    this.addressBookList,
    this.lastSentList,
  });

  @override
  List<Object?> get props => [
    status,
    addressBookList,
    lastSentList,
  ];

  AddressBookState copyWith({
    AddressBookStatusList? status,
    List<AddressBookModel>? addressBookList,
    List<AddressBookModel>? lastSentList,
  }) {
    return AddressBookState(
      status: status ?? this.status,
      addressBookList: addressBookList ?? this.addressBookList,
      lastSentList: lastSentList ?? this.lastSentList,
    );
  }
}
