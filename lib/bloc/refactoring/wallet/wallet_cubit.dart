import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/dfx_ramp_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/lock_staking_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';
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
    var neededRestore = applicationModel.networks.length * 5;
    var restored = 0;
    emit(state.copyWith(status: WalletStatusList.restore, restoreProgress: '($restored/$neededRestore)'));
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
        for(var network in applicationModel.networks){
          if(network.networkType.networkName.name == NetworkName.defichainMainnet.name){
            await (network.stakingList[0] as LockStakingProviderModel).signIn(
              account,
              password,
              applicationModel,
              network,
            );
            await (network.rampList[0] as DFXRampModel).signIn(
              account,
              password,
              applicationModel,
              network,
            );
          }
        }

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
        restored++;
        emit(state.copyWith(status: WalletStatusList.restore, restoreProgress: '($restored/$neededRestore)'));
      });
      hasHistory = presentBalance;
      if (presentBalance) {
        if(restored + 1 >= neededRestore){
          neededRestore += applicationModel.networks.length * 5;
        }
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

  loadWalletDetails({ApplicationModel? application}) async {
    try {
      // List<AbstractAccountModel> accounts = await StorageService.loadAccounts();
      ApplicationModel applicationModel =
          application ?? await StorageService.loadApplication();

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

  List<String> getMnemonic(String password){
    return state.applicationModel!.getMnemonic(password);
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
    )..networks = state.applicationModel!.networks;

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

  editAccount(String name, int index) async {
    ApplicationModel applicationModel = state.applicationModel!;
    applicationModel.accounts.firstWhere((element) => element.accountIndex == index).changeName(name);
      if(applicationModel.activeAccount!.accountIndex == index){
        applicationModel.activeAccount!.changeName(name);
      }

    StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      applicationModel: applicationModel,
    ));
  }

  updateActiveAccount(int index) async {
    emit(state.copyWith(
      status: WalletStatusList.loading,
    ));
    ApplicationModel applicationModel = state.applicationModel!;
    AbstractAccountModel account = applicationModel.accounts.firstWhere((element) => element.accountIndex == index);
    applicationModel.activeAccount = account;

    StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      status: WalletStatusList.success,
      applicationModel: applicationModel,
    ));
  }
  addNewAccount(String name) async {
    emit(state.copyWith(
      status: WalletStatusList.loading,
    ));
    ApplicationModel applicationModel = state.applicationModel!;
    int maxIndex = 0;
    applicationModel.accounts.forEach((element) => element.accountIndex > maxIndex ? maxIndex = element.accountIndex : null);
    SourceSeedModel source = applicationModel.sourceList.values.first;
    AbstractAccountModel account = await AccountModel.fromPublicKeys(networkList: applicationModel.networks,  accountIndex: maxIndex+1, publicKeyMainnet: source.publicKeyMainnet, publicKeyTestnet: source.publicKeyTestnet, sourceId: source.id);
    account.changeName(name);
    applicationModel.accounts.add(account);

    StorageService.saveApplication(applicationModel);

    emit(state.copyWith(
      status: WalletStatusList.success,
      applicationModel: applicationModel,
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

  signUpToRamp(String password) async {
    try {
      final applicationModel = state.applicationModel;
      await (applicationModel!.activeNetwork!.rampList[0] as DFXRampModel).signUp(
        state.activeAccount,
        password,
        state.applicationModel!,
        state.activeNetwork,
      );

      await StorageService.saveApplication(applicationModel);

      emit(state.copyWith(
        status: WalletStatusList.success,
        applicationModel: applicationModel,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: WalletStatusList.failure,
      ));
    }
  }
}
