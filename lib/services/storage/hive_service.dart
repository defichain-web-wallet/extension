import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:defichaindart/src/models/networks.dart' as networks;

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
}
