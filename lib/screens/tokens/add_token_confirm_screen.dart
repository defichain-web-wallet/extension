import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/logger_service.dart';
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

class AddTokenConfirmScreen extends StatefulWidget {
  final List<String> arguments;

  const AddTokenConfirmScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<AddTokenConfirmScreen> createState() => _AddTokenConfirmScreenState();
}

class _AddTokenConfirmScreenState extends State<AddTokenConfirmScreen>
    with ThemeMixin {
  TextEditingController searchController = TextEditingController();
  TokensHelper tokenHelper = TokensHelper();
  String titleText = 'Add token';
  List<String> symbols = [];

  @override
  Widget build(BuildContext context) {
    symbols = widget.arguments;
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            if (accountState.status == AccountStatusList.success) {
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
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              CustomTextFormField(
                                prefix: Icon(Icons.search),
                                addressController: searchController,
                                hintText: 'Search in Settings',
                                isBorder: true,
                                onChanged: (value) {},
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
                                child: ListView.builder(
                                  itemCount: symbols.length,
                                  itemBuilder: (BuildContext context, index) {
                                    String tokenName = symbols[index];
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 8,
                                        ),
                                        TokenListTile(
                                          isConfirm: true,
                                          onTap: () {
                                            print('12');
                                          },
                                          isSelect: false,
                                          imgPath:
                                              '${tokenHelper.getImageNameByTokenName(tokenName)}',
                                          tokenName: '$tokenName',
                                          availableTokenName:
                                              '${symbols[index]}',
                                          tokenColor: tokenHelper
                                              .getColorByTokenName(tokenName),
                                        ),
                                      ],
                                    );
                                  },
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
                                  callback: () {
                                    Navigator.pop(context);
                                  },
                                  label: 'Cancel',
                                ),
                              ),
                              NewPrimaryButton(
                                width: 104,
                                callback: () => submitAddToken(accountState),
                                title: 'Confirm',
                              ),
                            ],
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

  submitAddToken(state) async {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    for (var tokenName in symbols) {
      await accountCubit.addToken(tokenName);
    }
    LoggerService.invokeInfoLogg('user added new token');
    await Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => HomeScreen(
          snackBarMessage: 'Tokens have been added to your Assets',
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
