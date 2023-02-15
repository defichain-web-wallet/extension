import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field_swap.dart';
import 'package:defi_wallet/widgets/network/network_selector.dart';
import 'package:defi_wallet/widgets/swap/swap_account_selector_dialog.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';

import '../../../widgets/network/network_selector_swap.dart';
import '../../home/widgets/asset_select_swap.dart';

class AmountSelectorField extends StatefulWidget {
  final String? label;
  final String? selectedAsset;
  final AccountModel? account;
  final List<String>? assets;
  final GlobalKey<AssetSelectState>? selectKey;
  final GlobalKey<AssetSelectSwapState>? selectSwapKey;
  final TextEditingController? amountController;
  final Function(String)? onSelect;
  final Function(int)? onChangeAccount;
  final Function()? onAnotherSelect;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final FocusModel? focusModel;
  final Widget? suffixIcon;
  final bool? isShow;
  final bool? isFixedWidthAssetSelectorText;
  final bool isBorder;
  final bool isSwap;
  final String? amountInUsd;

  const AmountSelectorField({
    Key? key,
    this.label,
    this.selectedAsset,
    this.account,
    this.assets,
    this.selectKey,
    this.selectSwapKey,
    this.amountController,
    this.onSelect,
    this.onChangeAccount,
    this.onAnotherSelect,
    this.onChanged,
    this.focusNode,
    this.focusModel,
    this.suffixIcon,
    this.isShow,
    this.isFixedWidthAssetSelectorText = false,
    this.isBorder = false,
    this.isSwap = false,
    this.amountInUsd = '0.0',
  }) : super(key: key);

  @override
  State<AmountSelectorField> createState() => _AmountSelectorFieldState();
}

class _AmountSelectorFieldState extends State<AmountSelectorField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                widget.label!,
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            // TODO(eth): simply list assets that are supported by selectedNetwork
            // TODO: widget.label
            if (SettingsHelper.isBitcoin()) ...[
              Expanded(
                flex: 2,
                child: Container(
                  height: 20,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label == 'Swap from'
                            ? 'Bitcoin Mainnet'
                            : 'Defichain Mainnet',
                        style: Theme.of(context).textTheme.subtitle2!.apply(
                              color: Theme.of(context).textSelectionTheme.selectionColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 1,
              ),
            ],
          ],
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () {},
                child: widget.isSwap
                    ? AssetSelectSwap(
                        isBorder: widget.isBorder,
                        key: widget.selectSwapKey,
                        tokensForSwap: widget.assets!,
                        selectedToken: widget.selectedAsset!,
                        onSelect: widget.onSelect!,
                        onAnotherSelect: widget.onAnotherSelect!,
                        isFixedWidthText: widget.isFixedWidthAssetSelectorText!,
                      )
                    : AssetSelect(
                        isBorder: widget.isBorder,
                        key: widget.selectKey,
                        tokensForSwap: widget.assets!,
                        selectedToken: widget.selectedAsset!,
                        onSelect: widget.onSelect!,
                        onAnotherSelect: widget.onAnotherSelect!,
                        isFixedWidthText: widget.isFixedWidthAssetSelectorText!,
                      ),
              ),
            ),
            Expanded(
              flex: widget.isSwap ? 2 : 3,
              child: widget.isSwap
                  ? DecorationTextFieldSwap(
                      amountInUsd: widget.amountInUsd!,
                      selectedAsset: widget.selectedAsset!,
                      isBorder: widget.isBorder,
                      controller: widget.amountController,
                      focusNode: widget.focusNode,
                      focusModel: widget.focusModel,
                      onChanged: widget.onChanged,
                      suffixIcon: widget.suffixIcon,
                    )
                  : DecorationTextField(
                      isBorder: widget.isBorder,
                      controller: widget.amountController,
                      focusNode: widget.focusNode,
                      focusModel: widget.focusModel,
                      onChanged: widget.onChanged,
                      suffixIcon: widget.suffixIcon,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
