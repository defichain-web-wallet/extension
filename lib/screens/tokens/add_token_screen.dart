import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token_model.dart';
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
  List<String> symbols = List.empty(growable: true);
  TokensHelper tokenHelper = TokensHelper();
  int iterator = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokenState) {
                if (iterator == 0 && !isFullScreen) {
                  TokensCubit token = BlocProvider.of<TokensCubit>(context);

                  token.loadTokensFromStorage();
                  iterator++;
                }
                if (tokenState.status == TokensStatusList.success &&
                    accountState.status == AccountStatusList.success) {
                  List<TokensModel> availableTokens = [];

                  tokenState.foundTokens!.forEach((el) {
                    if (!el.isLPS) {
                      try {
                        accountState.activeAccount!.balanceList!
                            .firstWhere((token) => token.token == el.symbol);
                      } catch (err) {
                        if (!el.symbol.contains('v1') && !el.symbol.contains('BURN')) {
                          if (SettingsHelper.settings.network == "mainnet") {
                            availableTokens.add(el);
                          } else if (el.symbol != "TSLA") {
                            availableTokens.add(el);
                          }
                        }
                      }
                    }
                  });

                  return Scaffold(
                    drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                    endDrawer: isFullScreen ? null : AccountDrawer(
                      width: buttonSmallWidth,
                    ),
                    appBar: isFullScreen ? null : NewMainAppBar(
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
                                      TokensCubit token =
                                          BlocProvider.of<TokensCubit>(context);
                                      setState(() {
                                        token.search(tokenState.tokens, value);
                                      });
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
                                    height: availableTokens.length != 0
                                        ? isFullScreen
                                            ? 420
                                            : 288
                                        : isFullScreen
                                            ? 397
                                            : 297,
                                    child: availableTokens.length != 0
                                        ? ListView.builder(
                                            itemCount: availableTokens.length,
                                            itemBuilder:
                                                (BuildContext context, index) {
                                              String tokenName =
                                                  availableTokens[index]
                                                      .symbol
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
                                                        try {
                                                          accountState
                                                              .activeAccount!
                                                              .balanceList!
                                                              .firstWhere((el) =>
                                                                  el.token ==
                                                                  availableTokens[
                                                                          index]
                                                                      .symbol);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'This token already exist'),
                                                            ),
                                                          );
                                                        } catch (_) {
                                                          symbols.contains(
                                                                  availableTokens[
                                                                          index]
                                                                      .symbol)
                                                              ? symbols.remove(
                                                                  availableTokens[
                                                                          index]
                                                                      .symbol)
                                                              : symbols.add(
                                                                  availableTokens[
                                                                          index]
                                                                      .symbol!);
                                                          symbols = symbols
                                                              .toSet()
                                                              .toList();
                                                        }
                                                      });
                                                    },
                                                    isSelect: symbols.contains(
                                                        availableTokens[index]
                                                            .symbol),
                                                    tokenName: '$tokenName',
                                                    availableTokenName:
                                                        '${availableTokens[index].name}',
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
                                  if (symbols.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Chose a least one coin',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .snackBarTheme
                                            .backgroundColor,
                                      ),
                                    );
                                  } else {
                                    NavigatorService.push(context, AddTokenConfirmScreen(
                                      arguments: symbols,
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
      },
    );
  }
}
