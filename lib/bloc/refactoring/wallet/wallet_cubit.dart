import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';

import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:equatable/equatable.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;
import 'package:hive_flutter/hive_flutter.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletState());

  WalletState get walletState => state;

  createWallet(List<String> mnemonic, String password) async {
    emit(state.copyWith(status: WalletStatusList.loading));
    var seed = mnemonicToSeed(mnemonic.join(' '));
    var applicationModel = ApplicationModel({}, password);

    //TODO: maybe we need move this to different service
    var publicKeyMainnet = _getPublicKey(seed, false);
    var publicKeyTestnet = _getPublicKey(seed, true);

    var source = applicationModel.createSource(
        mnemonic, publicKeyTestnet, publicKeyMainnet);

    var account = await AccountModel.fromPublicKeys(
        networkList: applicationModel.networks,
        accountIndex: 0,
        publicKeyTestnet: publicKeyTestnet,
        publicKeyMainnet: publicKeyMainnet,
        sourceId: source.id);


    await StorageService.saveAccounts([account]);
    await StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      accountList: [account],
      activeAccount: account,
      applicationModel: applicationModel,
      status: WalletStatusList.success,
    ));
  }

  restoreWallet(List<String> mnemonic, String password) async {
    emit(state.copyWith(status: WalletStatusList.loading));
    var seed = mnemonicToSeed(mnemonic.join(' '));
    var applicationModel = ApplicationModel({}, password);
    List<AbstractAccountModel> accountList = [];

    bool hasHistory = true;

    //TODO: maybe we need move this to different service
    var publicKeyMainnet = _getPublicKey(seed, false);
    var publicKeyTestnet = _getPublicKey(seed, true);

    var source = applicationModel.createSource(
        mnemonic, publicKeyTestnet, publicKeyMainnet);
    var accountIndex = 0;
    while (hasHistory) {
      AbstractAccountModel account = await AccountModel.fromPublicKeys(
        networkList: applicationModel.networks,
        accountIndex: accountIndex,
        publicKeyTestnet: publicKeyTestnet,
        publicKeyMainnet: publicKeyMainnet,
        sourceId: source.id,
        isRestore: true,
      );

      //TODO: check tx history here
      bool presentBalance = false;
      applicationModel.networks.forEach((element) {
        var balanceList = account.getPinnedBalances(element);
        if (balanceList.length > 1 || balanceList.first.balance != 0) {
          presentBalance = true;
        }
      });
      hasHistory = presentBalance;
      if (presentBalance) {
        accountList.add(account);
        accountIndex++;
      }
    }
    // var network = applicationModel.networks[1];
    //var tx = await network.send(account:  accountList.first, address:  accountList.first.addresses[network.networkType.networkName.name]!, password: password, token:  accountList.first.getPinnedBalances(network)[1].token!, amount: 0.0001, applicationModel: applicationModel);
//print(tx);

    await StorageService.saveAccounts(accountList);
    await StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      accountList: accountList,
      activeAccount: accountList.first,
      applicationModel: applicationModel,
      status: WalletStatusList.success,
    ));
  }

  String _getPublicKey(Uint8List seed, bool isTestnet) {
    var network = isTestnet ? networks.testnet : networks.defichain;
    var bip = bip32.BIP32.fromSeedWithCustomKey(
        seed,
        "@defichain/jellyfish-wallet-mnemonic",
        bip32.NetworkType(
          bip32: bip32.Bip32Type(
            private: network.bip32.private,
            public: network.bip32.public,
          ),
          wif: network.wif,
        ));
    return bip32.BIP32
        .fromPublicKey(
            bip.publicKey,
            bip.chainCode,
            bip32.NetworkType(
                bip32: bip32.Bip32Type(
                  private: network.bip32.private,
                  public: network.bip32.public,
                ),
                wif: network.wif))
        .toBase58();
  }

// saveAccountsToStorage({
//   List<AccountModel>? accountsMainnet,
//   bip32.BIP32? masterKeyPairMainnetPublicKey,
//   bip32.BIP32? masterKeyPairMainnetPrivateKey,
//   List<AccountModel>? accountsTestnet,
//   bip32.BIP32? masterKeyPairTestnetPublicKey,
//   bip32.BIP32? masterKeyPairTestnetPrivateKey,
//   List<String>? mnemonic,
//   String password = "",
// }) async {
//   Codec<String, String> stringToBase64 = utf8.fuse(base64);
//   final accountsJson = [];
//   final accountsJsonTestnet = [];
//   var box = await Hive.openBox(HiveBoxes.client);
//
//   if (accountsMainnet != null) {
//     for (var account in accountsMainnet) {
//       accountsJson.add(account.toJson());
//     }
//
//     var jsonString = json.encode(accountsJson);
//     var encryptedAccounts = stringToBase64.encode(jsonString);
//     await box.put(HiveNames.accountsMainnet, encryptedAccounts);
//
//     if (masterKeyPairMainnetPublicKey != null) {
//       var encryptedMasterKeyPairPublic = stringToBase64.encode(
//         masterKeyPairMainnetPublicKey.toBase58(),
//       );
//       await box.put(
//         HiveNames.masterKeyPairMainnetPublic,
//         encryptedMasterKeyPairPublic,
//       );
//     }
//
//     if (password != '') {
//       var encryptedMasterKey = EncryptHelper.getEncryptedData(
//         masterKeyPairMainnetPrivateKey!.toBase58(),
//         password,
//       );
//       await box.put(
//         HiveNames.masterKeyPairMainnetPrivate,
//         encryptedMasterKey,
//       );
//
//       if (mnemonic != null) {
//         var encryptMnemonic =
//         EncryptHelper.getEncryptedData(mnemonic.join(','), password);
//         await box.put(HiveNames.savedMnemonic, encryptMnemonic);
//       }
//     }
//   }
//
//   if (accountsTestnet != null) {
//     for (var account in accountsTestnet) {
//       accountsJsonTestnet.add(account.toJson());
//     }
//
//     var jsonStringTestnet = json.encode(accountsJsonTestnet);
//     var encryptedAccounts = stringToBase64.encode(jsonStringTestnet);
//     await box.put(HiveNames.accountsTestnet, encryptedAccounts);
//
//     if (masterKeyPairTestnetPublicKey != null) {
//       var encryptedMasterKeyPairPublic = stringToBase64.encode(
//         masterKeyPairTestnetPublicKey.toBase58(),
//       );
//       await box.put(
//         HiveNames.masterKeyPairTestnetPublic,
//         encryptedMasterKeyPairPublic,
//       );
//     }
//
//     if (password != '') {
//       var encryptedMasterKey = EncryptHelper.getEncryptedData(
//         masterKeyPairTestnetPrivateKey!.toBase58(),
//         password,
//       );
//       await box.put(
//         HiveNames.masterKeyPairTestnetPrivate,
//         encryptedMasterKey,
//       );
//     }
//   }
//   await box.put(HiveNames.storageVersion, StorageConstants.storageVersion);
//   await box.close();
// }
}
