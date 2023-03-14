import 'package:crypt/crypt.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;

String mainnet = "mainnet";
String testnet = "testnet";

class StorageService {
  static updateExistUsers() async {
    var box = await Hive.openBox(HiveBoxes.client);
    var storageVersion = await box.get(HiveNames.storageVersion);
    var accounts = await box.get(HiveNames.accountsMainnet);
    if ((storageVersion == null ||
            storageVersion != StorageConstants.storageVersion) &&
        accounts != null) {
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      var box = await Hive.openBox(HiveBoxes.client);
      var encodedPassword = await box.get(HiveNames.password);
      await box.put(HiveNames.openedMnemonic, null);

      var mnemonic;
      var password = stringToBase64.decode(encodedPassword);

      encodedPassword  = Crypt.sha256(password).toString();

      try {
        var savedMnemonic = await box.get(HiveNames.savedMnemonic);
        if (savedMnemonic.split(',').length == 24) {
          var encryptMnemonic =
              EncryptHelper().getEncryptedData(savedMnemonic, password);
          await box.put(HiveNames.savedMnemonic, encryptMnemonic);
          mnemonic =
              EncryptHelper().getDecryptedData(encryptMnemonic, password);
        } else {
          mnemonic = EncryptHelper().getDecryptedData(savedMnemonic, password);
        }
      } catch (err) {
        mnemonic = '';
      }
      if (mnemonic == '') {
        //TODO: message "please restore your wallet from seed"
      }
      final seed = convertMnemonicToSeed(mnemonic.split(','));

      //mainnet start
      final masterKeyPairMainnet =
          HDWalletService().getMasterKeypairFormSeed(seed, mainnet);

      final masterKeyPairMainnetPublicKey = bip32.BIP32.fromPublicKey(
          masterKeyPairMainnet.publicKey, masterKeyPairMainnet.chainCode);

    var savedAccounts = await box.get(HiveNames.accountsMainnet);
      var decryptedAccounts =
      EncryptHelper().getDecryptedData(savedAccounts, password);

      final jsonString = decryptedAccounts;
      List<AccountModel> accountsMainnet = [];

      List<dynamic> jsonFromString = json.decode(jsonString);
      for (var account in jsonFromString) {
        var accountModel = AccountModel.fromJson(account);
        if(accountModel.bitcoinAddress == null){

          accountModel.bitcoinAddress = await HDWalletService().getAddressModelFromKeyPair(
              masterKeyPairMainnetPublicKey, accountModel.index, 'bitcoin');
          accountModel.bitcoinAddress!.blockchain = 'BTC';
        }
        accountsMainnet.add(accountModel);
      }

      var accountList = await AccountCubit().loadAccountDetails(accountsMainnet);
      accountsMainnet = accountList;
      //mainnet end

      //testnet start
      final masterKeyPairTestnet =
      HDWalletService().getMasterKeypairFormSeed(seed, testnet);

      final masterKeyPairTestnetPublicKey = bip32.BIP32.fromPublicKey(
          masterKeyPairTestnet.publicKey, masterKeyPairTestnet.chainCode);

       savedAccounts = await box.get(HiveNames.accountsTestnet);
       decryptedAccounts =
      EncryptHelper().getDecryptedData(savedAccounts, password);

      final jsonStringTestnet = decryptedAccounts;
      List<AccountModel> accountsTestnet = [];

      List<dynamic> jsonFromStringTestnet = json.decode(jsonStringTestnet);
      for (var account in jsonFromStringTestnet) {
        var accountModel = AccountModel.fromJson(account);
        if(accountModel.bitcoinAddress == null){
          accountModel.bitcoinAddress = await HDWalletService().getAddressModelFromKeyPair(
              masterKeyPairTestnetPublicKey, accountModel.index, 'bitcoin_testnet');
          accountModel.bitcoinAddress!.blockchain = 'BTC';
        }
        accountsTestnet.add(accountModel);
      }

      accountList = await AccountCubit().loadAccountDetails(accountsTestnet);
      accountsTestnet = accountList;
      //testnet end
      await box.delete(HiveNames.masterKeyPairTestnet);
      await box.delete(HiveNames.masterKeyPairMainnet);
      await box.put(HiveNames.password, encodedPassword);
      await box.close();
      //TODO: move functions saveAccountsToStorage and restore from cubit
      await AccountCubit().saveAccountsToStorage(
        accountsMainnet: accountsMainnet,
        masterKeyPairMainnetPublicKey: masterKeyPairMainnetPublicKey,
        masterKeyPairMainnetPrivateKey: masterKeyPairMainnet,
        accountsTestnet: accountsTestnet,
        masterKeyPairTestnetPublicKey: masterKeyPairTestnetPublicKey,
        masterKeyPairTestnetPrivateKey: masterKeyPairTestnet,
        mnemonic: mnemonic.split(','),
        password: password,
      );

      // hack for update storage to existing users
      throw Error.safeToString('need_password');
    }
  }
}
