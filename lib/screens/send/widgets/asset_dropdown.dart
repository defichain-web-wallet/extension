import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field.dart';
import 'package:flutter/material.dart';

class AssetDropdown extends StatelessWidget {
  final GlobalKey<AssetSelectState>? selectKeyFrom;
  final TextEditingController? amountController;
  final FocusNode? focusNode;
  final FocusModel? focusModel;
  final List<String>? assets;
  final String? assetFrom;
  final Function(String)? onSelect;
  final Function(String)? onChanged;
  final Function()? onPressed;

  const AssetDropdown(
      {Key? key,
      this.selectKeyFrom,
      this.amountController,
      this.focusNode,
      this.focusModel,
      this.assets,
      this.assetFrom,
      this.onSelect,
      this.onChanged,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AssetSelect(
            key: selectKeyFrom,
            tokensForSwap: assets!,
            selectedToken: assetFrom!,
            onSelect: onSelect!,
          ),
        ),
        Expanded(
          child: DecorationTextField(
            controller: amountController,
            focusNode: focusNode,
            focusModel: focusModel,
            onChanged: onChanged,
            suffixIcon: Container(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              child: TextButton(
                child: Text('MAX'),
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
