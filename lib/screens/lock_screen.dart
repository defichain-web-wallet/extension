import 'dart:convert';
import 'package:crypt/crypt.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/error/error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/errors/sentry_service.dart';
import 'package:defi_wallet/services/password_service.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/dialogs/restore_wallet_dialog.dart';
import 'package:defi_wallet/widgets/extension_welcome_bg.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/services/logger_service.dart';

class LockScreen extends StatefulWidget {
  final String? savedMnemonic;

  const LockScreen({Key? key, this.savedMnemonic}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SnackBarMixin, ThemeMixin {
  bool isPasswordObscure = true;
  bool isCorrectPassword = true;
  GlobalKey globalKey = GlobalKey();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  PasswordStatusList passwordStatus = PasswordStatusList.initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!isFullScreen(context))
            ExtensionWelcomeBg()
          else
            Center(
              child: Image.asset(
                'assets/images/jelly_protect.png',
                width: 191,
                height: 306,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(bottom: 42),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: authPaddingContainer.copyWith(
                        top: 0,
                        bottom: 0,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            PasswordTextField(
                              isOpasity: !isFullScreen(context),
                              height: 71,
                              controller: passwordController,
                              status: passwordStatus,
                              hint: 'Your password',
                              label: 'Password',
                              isShowObscureIcon: true,
                              isCaptionShown: false,
                              onEditComplete: () =>
                                  (globalKey.currentWidget! as ElevatedButton)
                                      .onPressed!(),
                              isObscure: isPasswordObscure,
                              onChanged: (val) {},
                              onPressObscure: () {
                                setState(() =>
                                    isPasswordObscure = !isPasswordObscure);
                              },
                              validator: (val) {
                                return isCorrectPassword
                                    ? null
                                    : "Incorrect password";
                              },
                            ),
                            StretchBox(
                              maxWidth: ScreenSizes.xSmall,
                              child: PendingButton(
                                'Unlock',
                                pendingText: 'Pending...',
                                isCheckLock: false,
                                globalKey: globalKey,
                                callback: (parent) => _submit(parent),
                              ),
                            ),
                            SizedBox(height: 20),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                child: Text(
                                  'Forgot password?',
                                  style: AppTheme.defiUnderlineText,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1,
                                        animation2) =>
                                        RecoveryScreen(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration:
                                    Duration.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _submit(parent) async {
    await PasswordService().handleCorrectAndRun(
      context,
      passwordController.text,
      isLockScreen: true,
      () async {
        await _restoreWallet(parent);
      },
    );
  }

  Future _restoreWallet(parent) async {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    setState(() {
      isCorrectPassword = true;
      formKey.currentState!.validate();
    });

    if (widget.savedMnemonic == null) {
      ApplicationModel? applicationModel;
      try {
        applicationModel = await StorageService.loadApplication();
      } catch (error, stackTrace) {
        print('Error: Failure load applicationModel');
        print(error);
        SentryService.captureException(
          ErrorModel(
            file: 'lock_screen.dart',
            method: 'build',
            exception: error.toString(),
          ),
          stackTrace: stackTrace,
        );
      }
      if (applicationModel == null) {
        showSnackBar(
          context,
          title: 'Failure loading application details',
          color: AppColors.txStatusError.withOpacity(0.1),
          prefix: Icon(
            Icons.close,
            color: AppColors.txStatusError,
          ),
        );
      } else {
        if (applicationModel.validatePassword(passwordController.text)) {
          setState(() {
            isCorrectPassword = true;
            formKey.currentState!.validate();
          });

          List<AbstractStakingProviderModel> accessTokensMap;

          bool isChangedVersion = await StorageService.isChangedVersion();
          if (isChangedVersion) {
            await _initEthereumInstance(applicationModel, parent);
          }

          try {
            accessTokensMap =
                applicationModel.activeNetwork!.getStakingProviders();

            if (accessTokensMap.length > 0) {
              AccessTokenModel accessTokenModel =
                  accessTokensMap[0].accessTokensMap[0]!;

              parent.emitPending(true);

              if (accessTokenModel.isExpire()) {
                await walletCubit.updateAccessKeys(
                  applicationModel,
                  passwordController.text,
                );
              }
            }
          } catch (error, stackTrace) {
            print('Error: Failure updating access tokens');
            print(error.toString());
            SentryService.captureException(
              ErrorModel(
                file: 'lock_screen.dart',
                method: '_restoreWallet',
                exception: error.toString(),
              ),
              stackTrace: stackTrace,
            );
          }
          await walletCubit.loadWalletDetails(
            application: applicationModel,
          );
          parent.emitPending(false);
          LoggerService.invokeInfoLogg('user was unlock wallet');

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  HomeScreen(isLoadTokens: true),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          _setInvalidPasswordField();
        }
      }
    } else {
      var encryptedPassword = await HiveService.getData(HiveNames.password);
      if (Crypt(encryptedPassword).match(passwordController.text)) {
        await _restoreExistingWallet(passwordController.text, context, parent);
      } else {
        _setInvalidPasswordField();
      }
    }
  }

  _restoreExistingWallet(
    String password,
    BuildContext context,
    dynamic parent,
  ) async {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    showDialog(
      barrierColor: AppColors.tolopea.withOpacity(0.06),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return RestoreWalletDialog(
          callbackOk: () async {
            parent.emitPending(true);

            List<String> mnemonic = EncryptHelper.getDecryptedData(
              widget.savedMnemonic,
              passwordController.text,
            ).split(',');

            try {
              var lastSent = await HiveService.getData(HiveNames.lastSent);
              var addressBook =
                  await HiveService.getData(HiveNames.addressBook);
              List<AddressBookModel> lastSentAddressBook = [];
              List<AddressBookModel> mainAddressBook = [];

              if (lastSent != null) {
                var lastSentList = json.decode(lastSent);
                lastSentAddressBook = List.generate(
                  lastSentList.length,
                  (index) => AddressBookModel.fromJson(
                    lastSentList[index],
                  ),
                );
              }
              if (addressBook != null) {
                var mainAddressBookList = json.decode(addressBook);
                mainAddressBook = List.generate(
                  mainAddressBookList.length,
                  (index) => AddressBookModel.fromJson(
                    mainAddressBookList[index],
                  ),
                );
              }
              await walletCubit.restoreWallet(
                mnemonic,
                passwordController.text,
                lastSent: lastSentAddressBook,
                addressBook: mainAddressBook,
              );
              await HiveService.update(HiveNames.savedMnemonic, null);
              parent.emitPending(false);

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HomeScreen(
                    isLoadTokens: true,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } catch (error, stackTrace) {
              parent.emitPending(false);
              showSnackBar(
                context,
                title: 'Something went wrong',
                color: AppColors.txStatusError.withOpacity(0.1),
                prefix: Icon(
                  Icons.close,
                  color: AppColors.txStatusError,
                ),
              );
              SentryService.captureException(
                ErrorModel(
                  file: 'lock_screen.dart',
                  method: '_restoreExistingWallet',
                  exception: error.toString(),
                ),
                stackTrace: stackTrace,
              );
            }
          },
        );
      },
    );
  }

  _initEthereumInstance(
    ApplicationModel applicationModel,
    dynamic parent,
  ) async {
    await showDialog(
      barrierColor: AppColors.tolopea.withOpacity(0.06),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return RestoreWalletDialog(
          callbackClose: () {
            parent.emitPending(false);
          },
          callbackOk: () async {
            SourceSeedModel source = applicationModel.sourceList.values.first;

            List<AbstractNetworkModel> ethereumNetworks =
            ApplicationModel.initNetworks()
                .where((network) => network is EthereumNetworkModel)
                .toList();
            bool hasEthereumNetworks = applicationModel.networks.where((
                network) => network is EthereumNetworkModel)
                .toList()
                .length > 0;
            if (!hasEthereumNetworks) {
              applicationModel.networks = [
                ...applicationModel.networks,
                ...ethereumNetworks,
              ];
            }
            applicationModel.networks.forEach((network) {
              applicationModel!.accounts.forEach((account) async {
                if (network is EthereumNetworkModel) {
                  try {
                    account.addresses[network.networkType.networkName.name] =
                    await network.createAddressFromPrivateKey(
                      account.accountIndex,
                      passwordController.text,
                      source,
                    );
                    account.pinnedBalances[network.networkType.networkName
                        .name] = await network.getAllBalances(
                      addressString: account
                          .addresses[network.networkType.networkName.name]!,
                    );
                  } catch (_) {
                    account.pinnedBalances[
                    network.networkType.networkName.name] = [
                      BalanceModel(balance: 0, token: network.getDefaultToken())
                    ];
                  }
                }
              });
            });
            try {
              await StorageService.saveApplication(applicationModel);
              await StorageService.updateStorageVersion(
                StorageConstants.storageVersion,
              );
            } catch (error, stackTrace) {
              SentryService.captureException(
                ErrorModel(
                  file: 'lock_screen.dart',
                  method: '_initEthereumInstance',
                  exception: error.toString(),
                ),
                stackTrace: stackTrace,
              );
            }
          },
        );
      },
    );
  }

  _setInvalidPasswordField() {
    setState(() {
      isCorrectPassword = false;
      formKey.currentState!.validate();
      passwordStatus = PasswordStatusList.error;
    });
  }
}
