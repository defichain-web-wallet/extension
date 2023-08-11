import 'dart:convert';
import 'dart:typed_data';

import 'package:base_codecs/base_codecs.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth/signup/signup_phrase_screen.dart';
import 'package:defi_wallet/screens/auth/welcome_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defi_wallet/utils/theme/theme_checker.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:flutter/services.dart' show rootBundle;

class WalletChecker extends StatefulWidget {
  @override
  State<WalletChecker> createState() => _WalletCheckerState();
}

class _WalletCheckerState extends State<WalletChecker> {
  SettingsHelper settingsHelper = SettingsHelper();
  LockHelper lockHelper = LockHelper();

  @override
  Widget build(BuildContext context) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    ApplicationModel? applicationModel;

    Future<void> checkWallets() async {
      final client = Web3Client('https://eth.llamarpc.com', Client());
      final jsonString = await rootBundle.loadString('assets/abi/erc20_abi.json');
      final jsonData =  jsonDecode(jsonString);
      print(jsonData);
      final contractAddress = EthereumAddress.fromHex('0xdAC17F958D2ee523a2206206994597C13D831ec7');
      final contractAbi = ContractAbi.fromJson(jsonString, 'Tether');
      final contract = DeployedContract(
        contractAbi,
        contractAddress,
      );

      // Get token name
      final symbolFunction = contract.function('symbol');
      final symbolResponse = await client.call(contract: contract, function: symbolFunction, params: []);
      final tokenSymbol = symbolResponse[0].toString();
      print(tokenSymbol);

      // Get token decimals
      final decimalsFunction = contract.function('decimals');
      final decimalsResponse = await client.call(contract: contract, function: decimalsFunction, params: []);
      final tokenDecimals = int.parse(decimalsResponse[0].toString());
      print(tokenDecimals);

      // Get token name
      final nameFunction = contract.function('name');
      final nameResponse = await client.call(contract: contract, function: nameFunction, params: []);
      final tokenName = nameResponse[0].toString();
      print(tokenName);

      // var a = bip32.BIP32.fromBase58('xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi');
      // // HEX.encode(a.privateKey);
      // print(a.privateKey);
      //
      // const String privateKey =
      //     'a2fd51b96dc55aeb14b30d55a6b3121c7b9c599500c1beb92a389c3377adc86e';
      // final credentials = EthPrivateKey.fromHex(privateKey);
      // print(credentials.address.toString());
      // // final credentials = EthPrivateKey.fromHex(privateKey);
      // // // credentials.privateKey.
      // // print(credentials.privateKey.toString());
      // // // EthPrivateKey.fromHex(hex);
      // // // print(credentials.);
      // final ethNetowrk = new EthereumNetworkModel(new NetworkTypeModel(
      //     networkName: NetworkName.ethereumMainnet,
      //     networkString: 'mainnet',
      //     isTestnet: false));
      // var test =  base58BitcoinEncode(credentials.publicKey.getEncoded());
      // final address = ethNetowrk.createAddress(test, 0);
      // print(address);
//       final address = credentials.address;

//       print(address.hexEip55);
//       print(address.hex);
// print(address);
      EtherAmount etherAmount = EtherAmount.fromBase10String(EtherUnit.ether, '1.01');
      print(etherAmount.getValueInUnit(EtherUnit.wei));
//       client.call(contract: contract, function: function, params: params)
var balance = await client.getBalance(EthereumAddress.fromHex('0x76778e046d73a5b8ce3d03749ce6b1b3d6a12e36'));
      print(balance);
//       var tx = await client.sendTransaction(
//         credentials,
//         fetchChainIdFromNetworkId: true, chainId: null,
//         Transaction(
//           from:  address,
//           to: EthereumAddress.fromHex('0x76778e046d73a5b8ce3d03749ce6b1b3d6a12e36'),
//           gasPrice: EtherAmount.inWei(BigInt.one),
//           maxGas: 100000,
//           value: EtherAmount.fromInt(EtherUnit.wei, 6250000000000000),
//         ),
//       );
//       print(tx);


      try {
        applicationModel = await StorageService.loadApplication();
      } catch (_) {
        applicationModel = null;
      }
      var box = await Hive.openBox(HiveBoxes.client);
      var savedMnemonic = await box.get(HiveNames.savedMnemonic);
      bool isOpenedMnemonic = await box.get(HiveNames.openedMnemonic) != null;
      String? openedMnemonic = await box.get(HiveNames.openedMnemonic);

      bool isRecoveryMnemonic =
          await box.get(HiveNames.recoveryMnemonic) != null;
      String? recoveryMnemonic = await box.get(HiveNames.recoveryMnemonic);

      bool isLedger =
          await box.get(HiveNames.ledgerWalletSetup, defaultValue: false);

      await settingsHelper.loadSettings();
      await box.close();

      if (savedMnemonic != null) {
        await lockHelper.lockWallet();

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ThemeChecker(
              LockScreen(
                savedMnemonic: savedMnemonic,
              ),
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        if (applicationModel != null || isLedger) {
          lockHelper.provideWithLockChecker(context, () async {
            try {
              await walletCubit.loadWalletDetails(
                application: applicationModel,
              );
              await Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ThemeChecker(HomeScreen(
                    isLoadTokens: true,
                  )),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } catch (err) {
              print(err);
            }
          });
        } else {
          if (isOpenedMnemonic) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(SignupPhraseScreen(mnemonic: openedMnemonic)),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else {
            if (isRecoveryMnemonic) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ThemeChecker(RecoveryScreen(
                    mnemonic: recoveryMnemonic,
                  )),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ThemeChecker(WelcomeScreen()),
                  // ThemeChecker(UiKit()),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          }
        }
      }
    }

    checkWallets();

    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Center(child: Loader()),
    );
  }
}
