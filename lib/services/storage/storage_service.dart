import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';

class StorageService {
  static Codec<String, String> stringToBase64 = utf8.fuse(base64);

  static Future saveAccounts(List<AbstractAccountModel> accounts) async {
    try {
      var data = accounts.map((e) => e.toJson()).toList();
      String jsonString = json.encode(data);
      var encryptedAccounts = stringToBase64.encode(jsonString);
      await HiveService.update(HiveNames.accounts, encryptedAccounts);
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future saveApplication(ApplicationModel applicationModel) async {
    try {
      final applicationModelJson = applicationModel.toJSON();
      final jsonString = json.encode(applicationModelJson);
      final encryptedApplication = stringToBase64.encode(jsonString);
      await HiveService.update(HiveNames.application, encryptedApplication);
    } catch (err) {
      print(err);
      throw err;
    }
  }

  static Future<ApplicationModel> loadApplication() async {
    try {
      var savedApplication = await HiveService.getData(HiveNames.application);
      var decryptedApplication = stringToBase64.decode(savedApplication);
      dynamic jsonList = json.decode(decryptedApplication);
      return ApplicationModel.fromJSON(jsonList);
    } catch (error) {
      throw error;
    }
  }
}
