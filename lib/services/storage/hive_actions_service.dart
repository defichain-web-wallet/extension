import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';

class HiveActionService {
  static Codec<String, String> stringToBase64 = utf8.fuse(base64);

  static Future saveAccounts(List<AbstractAccountModel> accounts) async {
    try {
      var data = accounts.map((e) => e.toJson()).toList();
      String jsonString = json.encode(data);
      var encryptedAccounts = stringToBase64.encode(jsonString);
      await HiveService.update(HiveNames.accounts, encryptedAccounts);
    } catch (err) {
      print(err);
    }
  }

  static Future<List<AbstractAccountModel>> loadAccounts() async {
    try {
      var savedAccounts = await HiveService.getData(HiveNames.accounts);
      var decryptedAccounts = stringToBase64.decode(savedAccounts);
      List<dynamic> jsonList = json.decode(decryptedAccounts);
      return List<AbstractAccountModel>.generate(
        jsonList.length,
        (index) => AccountModel.fromJson(jsonList[index]),
      );
    } catch (error) {
      throw error;
    }
  }
}
