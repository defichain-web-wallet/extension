import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<String> getMasterKey(
      String password, NetworkTypeModel network) async {
    String boxKey;

    if (network.isTestnet) {
      boxKey = HiveNames.masterKeyPairTestnetPrivate;
    } else {
      boxKey = HiveNames.masterKeyPairMainnetPrivate;
    }

    var box = await Hive.openBox(HiveBoxes.client);
    var encryptedMasterKey = await box.get(boxKey);
    return EncryptHelper.getDecryptedData(encryptedMasterKey, password);
  }

  static Future<dynamic> getData(
    NetworkTypeModel network,
    String key, {
    String password = '',
  }) async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);
      var data = await box.get(key);

      return password.isNotEmpty
          ? EncryptHelper.getDecryptedData(data, password)
          : data;
    } catch (error) {
      throw error;
    }
  }

  static Future<void> update(
    NetworkTypeModel network,
    String key,
    dynamic data, {
    String password = '',
  }) async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);

      if (password.isNotEmpty) {
        var encryptedData = EncryptHelper.getEncryptedData(data, password);
        await box.put(key, encryptedData);
      } else {
        await box.put(key, data);
      }
    } catch (error) {
      throw error;
    }
  }
}
