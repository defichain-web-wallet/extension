import 'dart:typed_data';

import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defichaindart/defichaindart.dart';

class BitcoinService {
  final networkHelper = NetworkHelper();

  bip32.BIP32 getMasterKeypairFormSeed(Uint8List seed, String networkString) {
    return bip32.BIP32
        .fromSeed(seed, networkHelper.getNetworkType(networkString));
  }

  ECPair getKeypairForPath(
      bip32.BIP32 masterKeypair, String path, String networkString) {
    return ECPair.fromPrivateKey(masterKeypair.derivePath(path).privateKey!,
        network: networkHelper.getNetwork(networkString));
  }

  ECPair getKeypairFromWIF(String wif, String networkString) {
    return ECPair.fromWIF(wif,
        network: networkHelper.getNetwork(networkString));
  }

  String derivePath(int account) {
    return "1129/0/0/$account";
  }

  String deriveLedgerPath(int account, bool isTestnet) {
    return "84'/${isTestnet ? "1" : "0"}'/0'/0/$account";
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
}
