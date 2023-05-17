import 'dart:convert';

import 'package:crypt/crypt.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';

class StorageService {
  static Codec<String, String> stringToBase64 = utf8.fuse(base64);

  static Future initWalletDetails({
    bool isExistAccessToken = false,
  }) async {
    try {
      await HiveService.update(HiveNames.kycStatus, 'show');
      await HiveService.update(HiveNames.tutorialStatus, 'show');
      if (isExistAccessToken) {
        await HiveService.update(
          HiveNames.generatedAccessToken,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
      await HiveService.update(HiveNames.openedMnemonic, null);
    } catch (err) {
      print(err);
    }
  }

  static Future savePassword(String password) async {
    try {
      var encryptedPassword = Crypt.sha256(password).toString();
      await HiveService.update(HiveNames.password, encryptedPassword);
    } catch (err) {
      print(err);
    }
  }

  static Future savePublicKeys(String mainnetKey, String testnetKey) async {
    try {
      var encryptedMainnetKey = stringToBase64.encode(mainnetKey);
      var encryptedTestnetKey = stringToBase64.encode(testnetKey);

      await HiveService.update(
        HiveNames.masterKeyPairMainnetPublic,
        encryptedMainnetKey,
      );
      await HiveService.update(
        HiveNames.masterKeyPairTestnetPublic,
        encryptedTestnetKey,
      );
    } catch (err) {
      print(err);
    }
  }

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
      String jsonString = json.encode(applicationModel.toJSON());
      var encryptedApplication = stringToBase64.encode(jsonString);
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
