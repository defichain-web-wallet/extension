import 'dart:math' as math;

import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/buy/iban_screen.dart';
import 'package:defi_wallet/screens/buy/buy_summary_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBuyToken extends StatefulWidget {
  const SearchBuyToken({Key? key}) : super(key: key);

  @override
  _SearchBuyTokenState createState() => _SearchBuyTokenState();
}

class _SearchBuyTokenState extends State<SearchBuyToken> with ThemeMixin {
  String symbol = '';
  String titleText = 'Select currency';
  String subtitleText = 'Select the token you want to buy';
  String subtitleTextOops =
      'We can`t find the token with such name.\nPlease try more';
  AssetByFiatModel? selectedAsset;
  TextEditingController searchController = TextEditingController();
  TokensHelper tokenHelper = TokensHelper();
  int iterator = 0;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;

  @override
  Widget build(BuildContext context) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    if (iterator == 0) {
      fiatCubit.loadAvailableAssets();
      iterator++;
    }
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (context, fiatState) {
            if (fiatState.status == FiatStatusList.loading) {
              return Loader();
            } else if (fiatState.status == FiatStatusList.failure) {
              Future.microtask(() => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        LockScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  )));
              return Container();
            } else {
              List<AssetByFiatModel> availableTokens = fiatState.foundAssets!;
              return Scaffold(
                drawerScrimColor: Color(0x0f180245),
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
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Text(
                                    subtitleText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .apply(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .color!
                                              .withOpacity(0.6),
                                        ),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              CustomTextFormField(
                                prefix: Icon(Icons.search),
                                addressController: searchController,
                                hintText: 'Search in Settings',
                                isBorder: true,
                                onChanged: (value) {
                                  TokensCubit token =
                                      BlocProvider.of<TokensCubit>(context);
                                  setState(() {
                                    FiatCubit fiat =
                                        BlocProvider.of<FiatCubit>(context);
                                    fiat.search(fiatState.assets, value);
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
                                height: 288,
                                child: availableTokens.length != 0
                                    ? ListView.builder(
                                        itemCount: availableTokens.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          String tokenName =
                                              availableTokens[index]
                                                  .name
                                                  .toString()
                                                  .replaceAll('d', '');
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 8,
                                              ),
                                              TokenListTile(
                                                isSingleSelect: true,
                                                onTap: () {
                                                  setState(() {
                                                    symbol ==
                                                            availableTokens[
                                                                    index]
                                                                .name
                                                        ? symbol = ''
                                                        : symbol =
                                                            availableTokens[
                                                                    index]
                                                                .name!;
                                                    if (symbol != '') {
                                                      selectedAsset =
                                                          availableTokens
                                                              .firstWhere(
                                                                  (element) =>
                                                                      element
                                                                          .name ==
                                                                      symbol);
                                                    } else {
                                                      selectedAsset = null;
                                                    }
                                                  });
                                                },
                                                isSelect: symbol ==
                                                    availableTokens[index].name,
                                                imgPath:
                                                    '${tokenHelper.getImageNameByTokenName(tokenName)}',
                                                tokenName: '$tokenName',
                                                availableTokenName:
                                                    '${availableTokens[index].dexName}',
                                                tokenColor:
                                                    availableTokens[index]
                                                        .color,
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Transform.rotate(
                                                    angle: -math.pi /
                                                        _logoRotateDeg,
                                                    child: Container(
                                                      height: _logoWidth,
                                                      width: _logoHeight,
                                                      child: Image(
                                                        image: AssetImage(
                                                          'assets/welcome_logo.png',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Oops!',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .color,
                                                ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            subtitleTextOops,
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .color!
                                                      .withOpacity(0.6),
                                                ),
                                          )
                                        ],
                                      ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 104,
                                child: AccentButton(
                                  label: 'Cancel',
                                  callback: () => Navigator.of(context).pop(),
                                ),
                              ),
                              NewPrimaryButton(
                                width: 104,
                                callback: () async {
                                  if (symbol == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Chose a coin',
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
                                    FiatCubit fiatCubit =
                                        BlocProvider.of<FiatCubit>(context);
                                    await fiatCubit.loadIbanList();

                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) {
                                          return IbanScreen(
                                            asset: selectedAsset!,
                                            routeWidget: BuySummaryScreen(
                                              asset: selectedAsset!,
                                            ),
                                          );
                                        },
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  }
                                },
                                title: 'Next',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
