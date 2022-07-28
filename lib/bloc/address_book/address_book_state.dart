part of 'address_book_cubit.dart';

enum AddressBookStatusList { initial, loading, success, restore, failure }

class AddressBookState extends Equatable {
  final List<AddressBookModel>? addressBookList;

  AddressBookState({
    this.addressBookList,
  });

  @override
  List<Object?> get props => [
    addressBookList,
  ];

  AddressBookState copyWith({
    List<AddressBookModel>? addressBookList,
  }) {
    return AddressBookState(
      addressBookList: addressBookList ?? this.addressBookList,
    );
  }

}
