import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/status_logo_and_title.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_token_confirm_screen.dart';

class AddTokenScreen extends StatefulWidget {
  const AddTokenScreen({Key? key}) : super(key: key);

  @override
  State<AddTokenScreen> createState() => _AddTokenScreenState();
}

class _AddTokenScreenState extends State<AddTokenScreen> with ThemeMixin {
  TextEditingController searchController = TextEditingController();
  String titleText = 'Add token';
  String subtitleTextOops =
      'We can`t find the token with such name.\nPlease try more';
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;
  List<TokenModel> tokens = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _loadAssetList();
  }

  _loadAssetList({String value = ''}) {
    RatesCubit ratesCubit =
    BlocProvider.of<RatesCubit>(context);
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    List<BalanceModel> balances = walletCubit.state
        .getBalances()
        .where((element) => element.token != null)
        .toList();
    List<TokenModel> existingTokens = balances.map((e) => e.token!).toList();

    ratesCubit.searchTokens(
      existingTokens: existingTokens,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    RatesCubit ratesCubit =
    BlocProvider.of<RatesCubit>(context);

    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<RatesCubit, RatesState>(
          builder: (context, ratesState) {
            if (ratesState.status == RatesStatusList.success) {
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
                              CustomTextFormField(
                                prefix: Icon(Icons.search),
                                addressController: searchController,
                                hintText: 'Search Token',
                                isBorder: true,
                                onChanged: (value) {
                                  _loadAssetList(value: value);
                                },
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                searchController.text == ''
                                    ? 'Popular Tokens'
                                    : 'Search result',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                                textAlign: TextAlign.start,
                              ),
                              Container(
                                height: isFullScreen
                                    ? ratesState.foundTokens.length != 0
                                        ? 478
                                        : 487
                                    : ratesState.foundTokens.length != 0
                                        ? 288
                                        : 297,
                                child: ratesState.foundTokens.length != 0
                                    ? ListView.builder(
                                        itemCount:
                                            ratesState.foundTokens.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          String tokenName = ratesState
                                              .foundTokens[index].symbol
                                              .toString();
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 8,
                                              ),
                                              TokenListTile(
                                                isSingleSelect: false,
                                                onTap: () {
                                                  setState(() {
                                                    tokens.contains(ratesState
                                                            .foundTokens[index])
                                                        ? tokens.remove(
                                                            ratesState
                                                                    .foundTokens[
                                                                index])
                                                        : tokens.add(ratesState
                                                                .foundTokens[
                                                            index]);
                                                    tokens =
                                                        tokens.toSet().toList();
                                                  });
                                                },
                                                isSelect: tokens.contains(
                                                    ratesState
                                                        .foundTokens[index]),
                                                tokenName: '$tokenName',
                                                availableTokenName:
                                                    '${ratesState.foundTokens[index].name}',
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Center(
                                        child: StatusLogoAndTitle(
                                          title: 'Oops!',
                                          subtitle: subtitleTextOops,
                                          isSmall: true,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          NewPrimaryButton(
                            width: buttonSmallWidth,
                            callback: () {
                              if (tokens.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Chose a least one coin',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .snackBarTheme
                                        .backgroundColor,
                                  ),
                                );
                              } else {
                                NavigatorService.push(
                                    context,
                                    AddTokenConfirmScreen(
                                      tokens: tokens,
                                    ));
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
            } else {
              return Loader();
            }
          },
        );
      },
    );
  }
}
