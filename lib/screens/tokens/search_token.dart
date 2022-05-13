import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_state.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
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

class SearchToken extends StatefulWidget {
  @override
  State<SearchToken> createState() => SearchTokenState();
}

class SearchTokenState extends State<SearchToken> {
  List<String> symbols = List.empty(growable: true);
  TextEditingController _searchController = TextEditingController();
  TokensHelper tokenHelper = TokensHelper();
  int iterator = 0;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) => ScaffoldConstrainedBox(
                  child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                        title: 'Add Tokens',
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
                        title: 'Add Tokens',
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
              })));

  Widget _buildBody(context, {isCustomBgColor = false}) => BlocBuilder<
          AccountCubit, AccountState>(
      builder: (context, state) =>
          BlocBuilder<TokensCubit, TokensState>(builder: (context, tokenState) {
            if (iterator == 0) {
              TokensCubit token = BlocProvider.of<TokensCubit>(context);

              token.loadTokens();
              iterator++;
            }
            if (tokenState is TokensLoadingState) {
              return Loader();
            } else if (tokenState is TokensLoadedState &&
                state is AccountLoadedState) {
              return Container(
                color: isCustomBgColor
                    ? Theme.of(context).dialogBackgroundColor
                    : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                                TokensCubit token =
                                    BlocProvider.of<TokensCubit>(context);
                                setState(() {
                                  token.search(tokenState.tokens, value);
                                });
                              },
                            ),
                            // _buildSearchField(context, tokenState),
                            SizedBox(height: 32),
                            Text(
                              'Popular tokens:',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        Expanded(
                          child: _buildTokensList(context, tokenState, state),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AccentButton(
                                    label: 'Cancel',
                                    callback: () =>
                                        Navigator.of(context).pop()),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Next',
                                  callback: () {
                                    if (symbols.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Chose a least one coin'),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddToken(arguments: symbols),
                                        ),
                                      );
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
            } else {
              return Loader();
            }
          }));

  Widget _buildTokensList(context, tokenState, accountState) {
    List<TokensModel> availableTokens = [];

    tokenState.foundTokens.forEach((el) {
      if (!el.isLPS) {
        try {
          accountState.activeAccount.balanceList
              .firstWhere((token) => token.token == el.symbol);
        } catch (err) {
          availableTokens.add(el);
        }
      }
    });
    return ListView.separated(
      shrinkWrap: true,
      itemCount: availableTokens.length,
      itemBuilder: (context, index) {
        String tokenName = availableTokens[index].symbol.toString();
        return Container(
          color: symbols.contains(availableTokens[index].symbol)
              ? Theme.of(context).textTheme.bodyText1!.decorationColor
              : Theme.of(context).scaffoldBackgroundColor,
          child: ListTile(
            leading: SvgPicture.asset(
              tokenHelper.getImageNameByTokenName(tokenName),
              height: 30,
              width: 30,
            ),
            title: Text(
              (tokenName != 'DFI' && tokenName != 'dUSD')
                  ? 'd' + tokenName
                  : tokenName,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () {
              setState(() {
                try {
                  accountState.activeAccount.balanceList.firstWhere(
                      (el) => el.token == availableTokens[index].symbol);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This token already exist'),
                    ),
                  );
                } catch (_) {
                  symbols.contains(availableTokens[index].symbol)
                      ? symbols.remove(availableTokens[index].symbol)
                      : symbols.add(availableTokens[index].symbol!);
                  symbols = symbols.toSet().toList();
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
