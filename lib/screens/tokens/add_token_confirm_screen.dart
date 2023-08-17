import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/services/logger_service.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTokenConfirmScreen extends StatefulWidget {
  final List<TokenModel> tokens;

  const AddTokenConfirmScreen({
    Key? key,
    required this.tokens,
  }) : super(key: key);

  @override
  State<AddTokenConfirmScreen> createState() => _AddTokenConfirmScreenState();
}

class _AddTokenConfirmScreenState extends State<AddTokenConfirmScreen>
    with ThemeMixin {
  TextEditingController searchController = TextEditingController();
  TokensHelper tokenHelper = TokensHelper();
  String titleText = 'Add token';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
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
                  children: [
                    Expanded(
                      child: Column(
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
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.tokens.length,
                              itemBuilder: (BuildContext context, index) {
                                TokenModel token = widget.tokens[index];
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 8,
                                    ),
                                    TokenListTile(
                                      isConfirm: true,
                                      isSelect: false,
                                      tokenName: token.displaySymbol,
                                      availableTokenName:
                                      token.name,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 104,
                          child: AccentButton(
                            callback: () {
                              NavigatorService.pop(context);
                            },
                            label: 'Cancel',
                          ),
                        ),
                        NewPrimaryButton(
                          width: 104,
                          callback: () => submitAddToken(),
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
      },
    );
  }

  submitAddToken() async {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    await tokensCubit.addTokens(context, widget.tokens);

    LoggerService.invokeInfoLogg('user added new token');
    NavigatorService.pushReplacement(context, null);
  }
}
