import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HDWalletService {
  final networkHelper = NetworkHelper();

  bip32.BIP32 getMasterKeypairFormSeed(Uint8List seed, String networkString) {
    return bip32.BIP32.fromSeedWithCustomKey(
        seed,
        "@defichain/jellyfish-wallet-mnemonic",
        networkHelper.getNetworkType(networkString));
  }

  ECPair getKeypairForPath(
      bip32.BIP32 masterKeypair, String path, String networkString) {
    return ECPair.fromPublicKey(masterKeypair.derivePath(path).publicKey,
        network: networkHelper.getNetwork(networkString));
  }

  ECPair getKeypairForPathPrivateKey(
      bip32.BIP32 masterKeypair, String path, String networkString) {
    // print(masterKeypair.derivePath(path).publicKey!);
    return ECPair.fromPrivateKey(masterKeypair.derivePath(path).privateKey!,
        network: networkHelper.getNetwork(networkString));
  }

  ECPair getKeypairFromWIF(String wif, String networkString) {
    return ECPair.fromWIF(wif,
        network: networkHelper.getNetwork(networkString));
  }

  Future<ECPair> getKeypairFromStorage(
      String? password, int accountIndex) async {
    var networkString = NetworkHelper().getNetworkString();
    String network;
    String boxKey;
    if (SettingsHelper.isBitcoin()) {
      if (networkString == 'testnet') {
        network = 'bitcoin_testnet';
      } else {
        network = 'bitcoin';
      }
    } else {
      network = networkString;
    }

    if (networkString == 'testnet') {
      boxKey = HiveNames.masterKeyPairTestnetPrivate;
    } else {
      boxKey = HiveNames.masterKeyPairMainnetPrivate;
    }

    var box = await Hive.openBox(HiveBoxes.client);
    var encryptedMasterKey = await box.get(boxKey);
    var masterKey =
        EncryptHelper.getDecryptedData(encryptedMasterKey, password);

    return getKeypairForPathPrivateKey(
        bip32.BIP32
            .fromBase58(masterKey, networkHelper.getNetworkType(network)),
        derivePath(accountIndex),
        network);
  }

  static String derivePath(int account) {
    return "1129/0/0/$account";
  }

  Future<String> getAddressFromKeyPair(
      ECPair keyPair, String networkString) async {
    final address = P2WPKH(
      data: PaymentData(
        pubkey: keyPair.publicKey,
      ),
      network: networkHelper.getNetwork(networkString),
    ).data!.address;
    return address!;
  }

  Future<AddressModel> getAddressModelFromKeyPair(
      bip32.BIP32 masterKeyPair, accountIndex, String networkString) async {
    final keyPair = getKeypairForPath(
        masterKeyPair, derivePath(accountIndex), networkString);
    final addressString = await getAddressFromKeyPair(keyPair, networkString);
    return AddressModel(address: addressString, account: accountIndex);
  }

  Future<ECPair> getPrivateKey(
      AccountModel accountModel, String address, String network) async {
    var addressModel = accountModel.addressList!
        .firstWhere((element) => element.address == address);
    var box = await Hive.openBox(HiveBoxes.client);

    var encodedPassword = await box.get(HiveNames.password);

    var stringToBase64 = utf8.fuse(base64);
    var password = stringToBase64.decode(encodedPassword);
    var masterKeyName;

    if (network == "testnet") {
      masterKeyName = HiveNames.masterKeyPairTestnet;
    } else {
      masterKeyName = HiveNames.masterKeyPairMainnet;
    }

    var savedMasterKey = box.get(masterKeyName);
    var decryptedMasterKey =
        EncryptHelper.getDecryptedData(savedMasterKey, password);
    var networkType = NetworkHelper().getNetworkType(network);
    final masterKeyPair =
        bip32.BIP32.fromBase58(decryptedMasterKey, networkType);
    final keyPair = getKeypairForPath(
        masterKeyPair, derivePath(addressModel.index!), network);

    return keyPair;
  }
}
