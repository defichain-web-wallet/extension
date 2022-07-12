import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/buy/iban_screen.dart';
import 'package:defi_wallet/screens/buy/purchase_overview_screen.dart';
import 'package:defi_wallet/screens/tokens/add_token.dart';
import 'package:defi_wallet/screens/tokens/widgets/search_field.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchBuyToken extends StatefulWidget {
  const SearchBuyToken({Key? key}) : super(key: key);

  @override
  _SearchBuyTokenState createState() => _SearchBuyTokenState();
}

class _SearchBuyTokenState extends State<SearchBuyToken> {
  String symbol = '';
  AssetByFiatModel? selectedAsset;
  TextEditingController _searchController = TextEditingController();
  TokensHelper tokenHelper = TokensHelper();
  int iterator = 0;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        if (iterator == 0) {
          fiatCubit.loadAvailableAssets(accountState.accessToken!);
          iterator++;
        }
        return BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) => ScaffoldConstrainedBox(
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < ScreenSizes.medium) {
                return Scaffold(
                  appBar: MainAppBar(
                      title: 'Select the token you want to buy',
                      isShowBottom: !(state is TransactionInitialState),
                      height: !(state is TransactionInitialState)
                          ? toolbarHeightWithBottom
                          : toolbarHeight),
                  body: _buildBody(context),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Scaffold(
                    appBar: MainAppBar(
                      title: 'Select the token you want to buy',
                      isShowBottom: !(state is TransactionInitialState),
                      height: !(state is TransactionInitialState)
                          ? toolbarHeightWithBottom
                          : toolbarHeight,
                      isSmall: true,
                    ),
                    body: _buildBody(context, isCustomBgColor: true),
                  ),
                );
              }
            }),
          ),
        );
      },
    );
  }

  Widget _buildBody(context, {isCustomBgColor = false}) =>
      BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) =>
            BlocBuilder<FiatCubit, FiatState>(builder: (context, fiatState) {
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
                ))
            );
            return Container();
          } else {
            return Container(
              color: isCustomBgColor
                  ? Theme.of(context).dialogBackgroundColor
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: StretchBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 8),
                          SearchField(
                            controller: _searchController,
                            onChanged: (value) {
                              FiatCubit fiat =
                              BlocProvider.of<FiatCubit>(context);
                              fiat.search(fiatState.assets, value);
                            },
                          ),
                          SizedBox(height: 32),
                          Text(
                            'Popular tokens:',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      Expanded(
                        child: _buildTokensList(context, fiatState, state),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AccentButton(
                                  label: 'Cancel',
                                  callback: () => Navigator.of(context).pop()),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Next',
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
                                    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

                                    await fiatCubit.loadIbanList(state.accessToken!, selectedAsset!);

                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                              animation2) =>
                                              IbanScreen(
                                                asset: selectedAsset!,
                                                routeWidget: PurchaseOverviewScreen(asset: selectedAsset!),
                                              ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                          Duration.zero,
                                        ));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }),
      );

  Widget _buildTokensList(context, fiatState, accountState) {
    List<AssetByFiatModel> availableTokens = fiatState.foundAssets;


    return ListView.separated(
      shrinkWrap: true,
      itemCount: availableTokens.length,
      itemBuilder: (context, index) {
        String tokenName =
            availableTokens[index].name.toString().replaceAll('d', '');
        return Container(
          color: symbol == availableTokens[index].name
              ? Theme.of(context).textTheme.bodyText1!.decorationColor
              : Theme.of(context).scaffoldBackgroundColor,
          child: ListTile(
            leading: SvgPicture.asset(
              tokenHelper.getImageNameByTokenName(tokenName),
              height: 30,
              width: 30,
            ),
            title: Text(tokenHelper.getTokenWithPrefix(tokenName),
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              setState(() {
                symbol == availableTokens[index].name
                    ? symbol = ''
                    : symbol = availableTokens[index].name!;
                if (symbol != '') {
                  selectedAsset = availableTokens.firstWhere((element) => element.name == symbol);
                } else {
                  selectedAsset = null;
                }
              });
            },
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 4,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
