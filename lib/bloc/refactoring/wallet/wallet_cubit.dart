import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:equatable/equatable.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletState());

  WalletState get walletState => state;

  int toSatoshi(double value){
    return state.activeNetwork.toSatoshi(value);
  }
  double fromSatoshi(int value){
    return state.activeNetwork.fromSatoshi(value);
  }

  createWallet(List<String> mnemonic, String password) async {
    emit(state.copyWith(status: WalletStatusList.loading));
    var seed = mnemonicToSeed(mnemonic.join(' '));
    var applicationModel = ApplicationModel(sourceList: {}, password: password);

    //TODO: maybe we need move this to different service
    var publicKeyMainnet = _getPublicKey(seed, false);
    var publicKeyTestnet = _getPublicKey(seed, true);

    var source = applicationModel.createSource(
        mnemonic, publicKeyTestnet, publicKeyMainnet, password);

    var account = await AccountModel.fromPublicKeys(
        networkList: applicationModel.networks,
        accountIndex: 0,
        publicKeyTestnet: publicKeyTestnet,
        publicKeyMainnet: publicKeyMainnet,
        sourceId: source.id);

    applicationModel.activeAccount = account;
    applicationModel.accounts = [account];

    await StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      applicationModel: applicationModel,
      status: WalletStatusList.success,
    ));
  }

  restoreWallet(List<String> mnemonic, String password) async {
    emit(state.copyWith(status: WalletStatusList.loading));
    var seed = mnemonicToSeed(mnemonic.join(' '));
    var applicationModel = ApplicationModel(sourceList: {}, password: password);
    List<AbstractAccountModel> accountList = [];

    bool hasHistory = true;

    //TODO: maybe we need move this to different service
    var publicKeyMainnet = _getPublicKey(seed, false);
    var publicKeyTestnet = _getPublicKey(seed, true);

    var source = applicationModel.createSource(
      mnemonic,
      publicKeyTestnet,
      publicKeyMainnet,
    password
    );

    var accountIndex = 0;
    while (hasHistory) {
      late AbstractAccountModel account;
      try {
        account = await AccountModel.fromPublicKeys(
          networkList: applicationModel.networks,
          accountIndex: accountIndex,
          publicKeyTestnet: publicKeyTestnet,
          publicKeyMainnet: publicKeyMainnet,
          sourceId: source.id,
          isRestore: true,
        );
      } catch (_) {
        print(_);
        rethrow;
      }

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

    applicationModel.accounts = accountList;
    applicationModel.activeAccount = accountList.first;

    // await StorageService.saveAccounts(accountList);
    await StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      applicationModel: applicationModel,
      status: WalletStatusList.success,
    ));
  }

  loadWalletDetails() async {
    try {
      // List<AbstractAccountModel> accounts = await StorageService.loadAccounts();
      ApplicationModel applicationModel = await StorageService.loadApplication();

      // applicationModel.activeAccount = applicationModel.accounts.first;

      emit(state.copyWith(
        applicationModel: applicationModel,
        status: WalletStatusList.success,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: WalletStatusList.failure,
      ));
    }
  }

  bool validatePassword(String password) {
    return state.applicationModel!.validatePassword(password);
  }

  changeActiveNetwork(AbstractNetworkModel network) async {
    ApplicationModel applicationModel = ApplicationModel(
      sourceList: state.applicationModel!.sourceList,
      encryptedPassword: state.applicationModel!.password,
      activeAccount: state.applicationModel!.activeAccount,
      accounts: state.applicationModel!.accounts,
      activeNetwork: network,
    );

    StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      applicationModel: applicationModel,
    ));
  }

  updateAccountBalances() async {
    emit(state.copyWith(
      status: WalletStatusList.update,
      applicationModel: state.applicationModel,
    ));
    final networkName =
        state.applicationModel!.activeNetwork!.networkType.networkName.name;
    final balances =
        await state.applicationModel!.activeNetwork!.getAllBalances(
      addressString: state.activeAccount.addresses[networkName]!,
    );
    state.applicationModel!.activeAccount!.pinnedBalances[networkName] =
        balances;

    // TODO: maybe need to save applicationModel during another action
    StorageService.saveApplication(state.applicationModel!);

    emit(state.copyWith(
      status: WalletStatusList.success,
      applicationModel: state.applicationModel,
    ));
  }

  getCurrentNetwork(){
    return state.applicationModel!.activeNetwork;
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