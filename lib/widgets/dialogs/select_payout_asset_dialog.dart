import 'dart:ui';

import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/mixins/dialog_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/add_token/token_list_tile.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dialogs/choose_payout_strategy_dialog.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectPayoutAssetDialog extends StatefulWidget {
  const SelectPayoutAssetDialog({Key? key}) : super(key: key);

  @override
  State<SelectPayoutAssetDialog> createState() =>
      _SelectPayoutAssetDialogState();
}

class _SelectPayoutAssetDialogState extends State<SelectPayoutAssetDialog>
    with ThemeMixin, DialogMixin {
  String titleText = 'Select your payout asset';
  String? selectedAssetName;
  TextEditingController searchController = TextEditingController();
  late List<TokenModel> assets;

  @override
  Widget build(BuildContext dialogContext) {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(dialogContext);

    return BlocBuilder<LockCubit, LockState>(
      builder: (context, lockState) {

        assets = lockState.selectedAssets!;
        assets.sort((a, b) => b.id.compareTo(a.id));

        selectedAssetName = selectedAssetName ?? assets[0].name;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: AlertDialog(
            backgroundColor: isDarkTheme()
                ? DarkColors.drawerBgColor
                : LightColors.drawerBgColor,
            insetPadding: EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              side: isDarkTheme()
                  ? BorderSide(color: DarkColors.drawerBorderColor)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            actionsPadding: EdgeInsets.only(
              bottom: 24,
              right: 14,
              left: 14,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 104,
                    child: AccentButton(
                      callback: () {
                        Navigator.pop(dialogContext);
                      },
                      label: 'Cancel',
                    ),
                  ),
                  NewPrimaryButton(
                    width: 104,
                    title: 'Confirm',
                    callback: () {
                      Navigator.pop(dialogContext);
                      showAppDialog(
                        ChoosePayoutStrategyDialog(
                          assetName: selectedAssetName!,
                        ),
                        dialogContext,
                      );
                    },
                  ),
                ],
              ),
            ],
            contentPadding: EdgeInsets.only(
              top: 16,
              bottom: 0,
              left: 16,
              right: 16,
            ),
            content: Stack(
              children: [
                Container(
                  width: 312,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        child: Text(
                          titleText,
                          style: Theme.of(context).textTheme.headline2!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.headline5!.color),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 8,
                          ),
                          SelectorTabElement(
                            callback: () {
                              lockCubit.updateLockAssetCategory(LockAssetCryptoCategory.Crypto);
                            },
                            title: 'Crypto assets',
                            isSelect: lockState.lockActiveAssetCategory == LockAssetCryptoCategory.Crypto,
                          ),
                          SizedBox(
                            width: 24,
                          ),
                          SelectorTabElement(
                            callback: () {
                              lockCubit.updateLockAssetCategory(LockAssetCryptoCategory.Stock);
                            },
                            isSelect: lockState.lockActiveAssetCategory == LockAssetCryptoCategory.Stock,
                            title: 'dTokens',
                          ),
                          SizedBox(
                            width: 24,
                          ),
                          SelectorTabElement(
                            callback: () {
                              lockCubit.updateLockAssetCategory(LockAssetCryptoCategory.PoolPair);
                            },
                            isSelect: lockState.lockActiveAssetCategory == LockAssetCryptoCategory.PoolPair,
                            title: 'LP Tokens',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField(
                        prefix: Icon(Icons.search),
                        addressController: searchController,
                        hintText: 'Search Token',
                        isBorder: true,
                        onChanged: (value) {},
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: ListView.builder(
                            itemCount: assets.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  TokenListTile(
                                    isSingleSelect: true,
                                    isSelect: assets[index].symbol == selectedAssetName,
                                    tokenName: assets[index].symbol,
                                    isDense: true,
                                    onTap: () {
                                      setState(() {
                                        selectedAssetName = assets[index].symbol;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).dividerColor.withOpacity(0.5),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
