import 'dart:ui';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
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
  TokensHelper tokenHelper = TokensHelper();
  int iterator = 0;

  @override
  void initState() {
    super.initState();
    TokensCubit token = BlocProvider.of<TokensCubit>(context);

    token.init(context);
  }
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
            return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokenState) {
                if (tokenState.status == TokensStatusList.success) {

                  return Scaffold(
                    drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                    endDrawer: AccountDrawer(
                      width: buttonSmallWidth,
                    ),
                    appBar: NewMainAppBar(
                      isShowLogo: false,
                    ),
                    body: Container(
                      padding: EdgeInsets.only(
                        top: 22,
                        bottom: 24,
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
                                  Row(
                                    children: [
                                      Text(
                                        titleText,
                                        style: headline2.copyWith(
                                            fontWeight: FontWeight.w700),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
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
                                    height: tokenState.foundTokens!.length != 0 ? 288 : 297,
                                    child: tokenState.foundTokens!.length != 0
                                        ? ListView.builder(
                                            itemCount: tokenState.foundTokens!.length,
                                            itemBuilder:
                                                (BuildContext context, index) {
                                              String tokenName =
                                                  tokenState.foundTokens![index]
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
                                                        tokens.contains(
                                                                  tokenState.foundTokens![
                                                                          index])
                                                              ? tokens.remove(
                                                                  tokenState.foundTokens![
                                                                          index])
                                                              : tokens.add(
                                                                  tokenState.foundTokens![
                                                                          index]);
                                                          tokens = tokens
                                                              .toSet()
                                                              .toList();
                                                        });
                                                    },
                                                    isSelect: tokens.contains(
                                                        tokenState.foundTokens![index]),
                                                    tokenName: '$tokenName',
                                                    availableTokenName:
                                                        '${tokenState.foundTokens![index].name}',
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
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                AddTokenConfirmScreen(
                                                  tokens: tokens,
                                        ),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
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
