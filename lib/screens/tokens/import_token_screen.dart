import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/screens/tokens/widgets/import_text_field.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_token_confirm_screen.dart';

class ImportTokenScreen extends StatefulWidget {
  const ImportTokenScreen({Key? key}) : super(key: key);

  @override
  State<ImportTokenScreen> createState() => _ImportTokenScreenState();
}

class _ImportTokenScreenState extends State<ImportTokenScreen>
    with ThemeMixin, SnackBarMixin {
  TextEditingController addressController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController precisionController = TextEditingController();
  String titleText = 'Import token';
  TokenModel? newToken;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            return Scaffold(
              drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
              endDrawer: isFullScreen
                  ? null
                  : AccountDrawer(
                width: buttonSmallWidth,
              ),
              appBar: isFullScreen
                  ? null
                  : NewMainAppBar(
                isShowLogo: false,
              ),
              body: Container(
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 22,
                  left: 16,
                  right: 16,
                ),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.scaffoldContainerBgColor
                      : LightColors.scaffoldContainerBgColor,
                  border: isDarkTheme()
                      ? Border.all(
                    width: 1.0,
                    color: Colors.white.withOpacity(0.05),
                  )
                      : null,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                    bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                  ),
                ),
                child: Center(
                  child: StretchBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PageTitle(
                              title: titleText,
                              isFullScreen: isFullScreen,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            ImportTextField(
                              label: 'Address',
                              hint: 'Entter contract address',
                              controller: addressController,
                              onChanged: (String value) async {
                                try {
                                  TokenModel token =
                                  await (walletState.activeNetwork
                                  as EthereumNetworkModel)
                                      .getTokenByContractAddress(
                                    value,
                                  );
                                  symbolController.text = token.symbol;
                                  precisionController.text =
                                      token.tokenDecimals.toString();
                                  newToken = token;
                                } catch (err) {
                                  print(err);
                                }
                              },
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            ImportTextField(
                              label: 'Symbol',
                              hint: 'Enter symbol of token',
                              controller: symbolController,
                              readonly: true,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            ImportTextField(
                              label: 'Precision',
                              hint: 'Enter decimal places',
                              controller: precisionController,
                              isNumber: true,
                              readonly: true,
                            ),
                          ],
                        ),
                        NewPrimaryButton(
                          width: buttonSmallWidth,
                          callback: () {
                            if (newToken == null) {
                              showSnackBar(
                                context,
                                title: 'Paste contract address',
                                color:
                                AppColors.txStatusError.withOpacity(0.1),
                                prefix: Icon(
                                  Icons.close,
                                  color: AppColors.txStatusError,
                                ),
                              );
                            } else {
                              List<BalanceModel> balances = walletState
                                  .activeAccount.getPinnedBalances(
                                  walletState.activeNetwork);
                              bool isExistBalance = balances.where((element) =>
                              element.token!.symbol == newToken!.symbol).length >
                                  0;
                              if (isExistBalance) {
                                showSnackBar(
                                  context,
                                  title: 'Token is already exist',
                                  color:
                                  AppColors.txStatusError.withOpacity(0.1),
                                  prefix: Icon(
                                    Icons.close,
                                    color: AppColors.txStatusError,
                                  ),
                                );
                              } else {
                                NavigatorService.push(
                                  context,
                                  AddTokenConfirmScreen(
                                    tokens: [newToken!],
                                    balances: [],
                                  ),
                                );
                              }
                            }
                          },
                          title: 'Continue',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
