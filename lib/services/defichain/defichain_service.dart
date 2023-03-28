import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:defichaindart/src/models/networks.dart' as networks;

class DefichainService {
  static ECPair getKeypairForPathPrivateKey(
      bip32.BIP32 masterKeypair, String path, NetworkType network) {
    return ECPair.fromPrivateKey(masterKeypair.derivePath(path).privateKey!,
        network: network);
  }

  static Future<ECPair> getKeypairFromStorage(String password, int accountIndex, NetworkName network) async{
    String boxKey;

    if(network == NetworkName.defichainTestnet){
      boxKey = HiveNames.masterKeyPairTestnetPrivate;
    } else{
      boxKey = HiveNames.masterKeyPairMainnetPrivate;
    }

    var box = await Hive.openBox(HiveBoxes.client);
    var encryptedMasterKey = await box.get(boxKey);
    var masterKey = EncryptHelper().getDecryptedData(encryptedMasterKey, password);

    return getKeypairForPathPrivateKey(bip32.BIP32.fromBase58(masterKey, getNetworkType(network)),derivePath(accountIndex),getNetwork(network));
  }

  static bip32.NetworkType getNetworkType(NetworkName networkName) {
    var network = getNetwork(networkName);
    return bip32.NetworkType(
      bip32: bip32.Bip32Type(
        private: network.bip32.private,
        public: network.bip32.public,
      ),
      wif: network.wif,
    );
  }

  static NetworkType getNetwork(NetworkName networkName) {
    switch (networkName) {
      case NetworkName.defichainMainnet:
        return networks.defichain;
      case NetworkName.defichainTestnet:
        return networks.defichain_testnet;
      default:
        throw 'Invalid network';
    }
  }


  static String derivePath(int account) {
    return "1129/0/0/$account";
  }
}