import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field.dart';
import 'package:flutter/material.dart';

class AmountSelectorField extends StatelessWidget {
  final String? label;
  final String? selectedAsset;
  final List<String>? assets;
  final GlobalKey<AssetSelectState>? selectKey;
  final TextEditingController? amountController;
  final Function(String)? onSelect;
  final Function()? onAnotherSelect;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final FocusModel? focusModel;
  final Widget? suffixIcon;
  final bool? isShow;
  final bool? isFixedWidthAssetSelectorText;

  const AmountSelectorField({
    Key? key,
    this.label,
    this.selectedAsset,
    this.assets,
    this.selectKey,
    this.amountController,
    this.onSelect,
    this.onAnotherSelect,
    this.onChanged,
    this.focusNode,
    this.focusModel,
    this.suffixIcon,
    this.isShow,
    this.isFixedWidthAssetSelectorText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: AssetSelect(
                  key: selectKey,
                  tokensForSwap: assets!,
                  selectedToken: selectedAsset!,
                  onSelect: onSelect!,
                  onAnotherSelect: onAnotherSelect!,
                  isFixedWidthText: isFixedWidthAssetSelectorText!,
                ),
              ),
            ),
            Expanded(
              child: DecorationTextField(
                  controller: amountController,
                  focusNode: focusNode,
                  focusModel: focusModel,
                  onChanged: onChanged,
                  suffixIcon: suffixIcon),
            ),
          ],
        ),
      ],
    );
  }
}
