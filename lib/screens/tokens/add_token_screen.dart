import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/screens/tokens/import_token_screen.dart';
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
import 'package:flutter_svg/flutter_svg.dart';

import 'add_token_confirm_screen.dart';

class AddTokenScreen extends StatefulWidget {
  const AddTokenScreen({Key? key}) : super(key: key);

  @override
  State<AddTokenScreen> createState() => _AddTokenScreenState();
}

class _AddTokenScreenState extends State<AddTokenScreen>
    with ThemeMixin, SnackBarMixin {
  TextEditingController searchController = TextEditingController();
  String titleText = 'Add token';
  String subtitleTextOops =
      'We can`t find the token with such name.\nPlease try more';
  List<TokenModel> tokens = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _loadAssetList();
  }

  _loadAssetList({String value = ''}) async {
    RatesCubit ratesCubit =
    BlocProvider.of<RatesCubit>(context);
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    List<BalanceModel> balances = walletCubit.state
        .getBalances()
        .where((element) => element.token != null)
        .toList();
    List<TokenModel> existingTokens = balances.map((e) => e.token!).toList();
    List<TokenModel> ethTokens = [];
    if (walletCubit.state.activeNetwork is EthereumNetworkModel) {
      ethTokens = await walletCubit.state.activeNetwork.getAvailableTokens();

      if (ethTokens.length > 0) {
        ratesCubit.searchTokens(
          existingTokens: existingTokens,
          value: value,
          allTokens: ethTokens,
        );
      }
    } else {
      ratesCubit.searchTokens(
        existingTokens: existingTokens,
        value: value,
      );
    }
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
              final availableTokens =
                  (walletCubit.state.activeNetwork is EthereumNetworkModel)
                      ? ratesState.tokens
                      : ratesState.foundTokens;

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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    PageTitle(
                                      title: titleText,
                                      isFullScreen: isFullScreen,
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          NavigatorService.push(
                                            context,
                                            ImportTokenScreen(),
                                          );
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.portage
                                                .withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/add_black.svg',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                availableTokens.length != 0
                                    ? Expanded(
                                      child: ListView.builder(
                                          itemCount:
                                              availableTokens.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            String tokenName = availableTokens[index].displaySymbol
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
                                                      tokens.contains(availableTokens[index])
                                                          ? tokens.remove(
                                                          availableTokens[
                                                                  index])
                                                          : tokens.add(availableTokens[
                                                              index]);
                                                      tokens =
                                                          tokens.toSet().toList();
                                                    });
                                                  },
                                                  isSelect: tokens.contains(
                                                      availableTokens[index]),
                                                  tokenName: '$tokenName',
                                                  availableTokenName:
                                                      '${availableTokens[index].name}',
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                    )
                                    : Center(
                                        child: StatusLogoAndTitle(
                                          title: 'Oops!',
                                          subtitle: subtitleTextOops,
                                          isSmall: true,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          NewPrimaryButton(
                            width: buttonSmallWidth,
                            callback: () {
                              if (tokens.isEmpty) {
                                showSnackBar(
                                  context,
                                  title: 'Chose a least one coin',
                                  color: AppColors.txStatusError.withOpacity(0.1),
                                  prefix: Icon(
                                    Icons.close,
                                    color: AppColors.txStatusError,
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
