import 'package:defi_wallet/constants/input_formatters.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/refactoring/fields/available_amount_text.dart';
import 'package:defi_wallet/widgets/refactoring/fields/converted_amount_text.dart';
import 'package:defi_wallet/widgets/refactoring/selectors/asset/asset_selector.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class AmountField extends StatefulWidget {
  final void Function(BalanceModel asset) onAssetSelect;
  final void Function(String value) onChanged;
  final TextEditingController controller;
  final List<BalanceModel> assets;
  final double? available;
  final String? suffix;
  final bool isDisabledSelector;
  final bool isDisableAvailable;
  final TxType? type;
  final BalanceModel? balance;

  AmountField({
    required this.onAssetSelect,
    required this.onChanged,
    required this.controller,
    required this.assets,
    this.type,
    this.balance,
    this.available = 35.02,
    this.suffix = '\$365.50',
    this.isDisabledSelector = false,
    this.isDisableAvailable = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  final FocusNode _focusNode = FocusNode();
  bool _onFocused = false;

  _onFocusChange() {
    if (double.tryParse(widget.controller.text) == 0) {
      widget.controller.text = '';
    }

    setState(() {
      _onFocused = _focusNode.hasFocus;
    });
  }

  _onSelectInputText() {
    _focusNode.requestFocus();
    if (widget.controller.text.isNotEmpty) {
      widget.controller.selection = TextSelection(
          baseOffset: 0, extentOffset: widget.controller.text.length);
    }
  }

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _onFocused
            ? GradientBoxBorder(
                gradient: gradientWrongMnemonicWord,
              )
            : Border.all(
                color: LightColors.amountFieldBorderColor.withOpacity(0.32),
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: inputFormatters,
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: (value) => widget.onChanged(value),
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 20,
                          ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(0.0),
                      ),
                    ),
                  ),
                ),
                AssetSelector(
                  assets: widget.assets,
                  selectedAsset: widget.balance!,
                  onSelect: (token) {
                    widget.controller.text = '0';
                    widget.onChanged(widget.controller.text);
                    widget.onAssetSelect(token);
                  },
                  isDisabled: widget.isDisabledSelector,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConvertedAmountText(
                  amount: double.tryParse(widget.controller.text),
                  token: widget.balance!.token!),
              !widget.isDisableAvailable
                  ? GestureDetector(
                      onTap: () {
                        if (widget.controller.text !=
                            widget.available.toString()) {
                          widget.controller.text = widget.available.toString();
                          widget.onChanged(widget.controller.text);
                          _focusNode.requestFocus();
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AvailableAmountText(
                          amount: widget.available!,
                        ),
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );
  }
}
