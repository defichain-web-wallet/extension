import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';

import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:equatable/equatable.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;

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

    var source = applicationModel.createSource(mnemonic, publicKeyTestnet, publicKeyMainnet);

    var account = await AccountModel.fromPublicKeys(
        networkList: applicationModel.networks,
        accountIndex: 0,
        publicKeyTestnet: publicKeyTestnet,
        publicKeyMainnet: publicKeyMainnet,
        sourceId: source.id);

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

    var source = applicationModel.createSource(mnemonic, publicKeyTestnet, publicKeyMainnet);
    var accountIndex = 0;
    while(hasHistory){
      AbstractAccountModel account = await AccountModel.fromPublicKeys(
          networkList: applicationModel.networks,
          accountIndex: accountIndex,
          publicKeyTestnet: publicKeyTestnet,
          publicKeyMainnet: publicKeyMainnet,
          sourceId: source.id,
          isRestore: true);
      accountList.add(account);
      //TODO: check tx history here
      bool presentBalance = false;
      applicationModel.networks.forEach((element) {
        var balanceList = account.getPinnedBalances(element);
        if(balanceList.length > 1){
          presentBalance = true;
        } else {
          if(balanceList.first.balance != 0){
            presentBalance = true;
          }
        }
      });
      hasHistory = presentBalance;

      accountIndex++;
    }

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
}
