import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';

class LedgerAccountModel extends AbstractAccountModel {
  final String address;
  final String pubKey;

  LedgerAccountModel({
    required String? id,
    required this.address,
    required this.pubKey,
    required String sourceId,
    required Map<String, List<BalanceModel>> pinnedBalances,
    required String name,
    required List<AddressBookModel> addressBook,
    required List<AddressBookModel> lastSend,
  }) : super(id, null, pubKey, sourceId, pinnedBalances, name, addressBook,
            lastSend);

  @override
  List<AbstractNetworkModel> getNetworkModelList(ApplicationModel model) {
    return model.networks
        .where((element) => !element.networkType.isLocalWallet)
        .toList();
  }

  factory LedgerAccountModel.fromJson(
      Map<String, dynamic> jsonModel, List<AbstractNetworkModel> networkList) {
    Map<String, List<BalanceModel>> pinnedBalances = {};

    var addressBookList = jsonModel["addressBook"] as List;
    final addressBook = List<AddressBookModel>.generate(
      addressBookList.length,
      (index) => AddressBookModel.fromJson(addressBookList[index]),
    );

    var lastSendList = jsonModel["lastSendList"] as List;
    final lastSend = List<AddressBookModel>.generate(
      lastSendList.length,
      (index) => AddressBookModel.fromJson(lastSendList[index]),
    );

    return LedgerAccountModel(
        id: jsonModel['id'],
        address: jsonModel['address'],
        pubKey: jsonModel['pubKey'],
        sourceId: jsonModel['sourceId'],
        pinnedBalances: pinnedBalances,
        name: jsonModel["name"],
        addressBook: addressBook,
        lastSend: lastSend);
  }

  @override
  String? getAddress(NetworkName networkName) {
    return this.address;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["sourceId"] = this.sourceId;
    data["pubKey"] = this.pubKey;
    data["address"] = this.address;
    data["name"] = this.name;
    data["type"] = "ledger";
    data["pinnedBalances"] = this.pinnedBalances.map((key, value) {
      List balancesJson = value.map((e) => e.toJSON()).toList();
      return MapEntry(key, balancesJson);
    });

    data["addressBook"] = this.addressBook.map((e) => e.toJson()).toList();
    data["lastSendList"] = this.lastSendList.map((e) => e.toJson()).toList();

    return data;
  }

  static Future<LedgerAccountModel> fromLedger(
      {required AbstractNetworkModel network,
      required String address,
      required String publicKey,
      required String sourceId,
      isRestore = false}) async {
    Map<String, List<BalanceModel>> pinnedBalances = {};

    return LedgerAccountModel(
        id: null,
        address: address,
        pubKey: publicKey,
        sourceId: sourceId,
        pinnedBalances: pinnedBalances,
        name: "Ledger",
        addressBook: [],
        lastSend: []);
  }
}
