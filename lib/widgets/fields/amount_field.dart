import 'package:defi_wallet/bloc/available_amount/available_amount_cubit.dart';
import 'package:defi_wallet/constants/input_formatters.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/selectors/asset/asset_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradient_borders/gradient_borders.dart';

class AmountField extends StatefulWidget {
  final void Function(TokensModel asset) onAssetSelect;
  final void Function(String value) onChanged;
  final TextEditingController controller;
  final TokensModel selectedAsset;
  final List<TokensModel> assets;
  final double? available;
  final String? suffix;
  final bool isDisabledSelector;
  final bool isAvailableTo;
  final TxType? type;
  final AccountModel? account;
  final BalanceModel? balance;

  AmountField({
    required this.onAssetSelect,
    required this.onChanged,
    required this.controller,
    required this.selectedAsset,
    required this.assets,
    this.type,
    this.account,
    this.balance,
    this.available = 35.02,
    this.suffix = '\$365.50',
    this.isDisabledSelector = false,
    this.isAvailableTo = true,
    Key? key,
  }) : super(key: key);

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  final FocusNode _focusNode = FocusNode();
  bool _onFocused = false;

  _onFocusChange() {
    if (widget.controller.text == '0') {
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

  _loadAvailableBalance(BuildContext context) {
    AvailableAmountCubit availableAmountCubit =
        BlocProvider.of<AvailableAmountCubit>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.type == TxType.send) {
        // await availableAmountCubit.getAvailable(
        //   widget.selectedAsset.symbol!,
        //   widget.type!,
        //   widget.account!,
        // );
      } else if (widget.type == null) {
        await availableAmountCubit.btcAvailableBalance(
          widget.available!,
        );
      }
      if (widget.type == TxType.swap || widget.type == TxType.addLiq) {
        if (widget.isAvailableTo) {
          // await availableAmountCubit.getAvailableTo(
          //   assetSymbol,
          //   widget.type!,
          //   widget.account!,
          // );
        } else {
          // await availableAmountCubit.getAvailableFrom(
          //   widget.selectedAsset.symbol!,
          //   widget.type!,
          //   widget.account!,
          // );
        }
      }
    });
  }

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var available = widget.balance!.balance.toString();

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      onDoubleTap: () => _onSelectInputText(),
      child: Container(
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
                    selectedAsset: widget.selectedAsset,
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
                Text(
                  '\$${widget.suffix!}',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .textTheme
                            .headline6!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.controller.text != widget.available.toString()) {
                      widget.controller.text = widget.available.toString();
                      widget.onChanged(widget.controller.text);
                      _focusNode.requestFocus();
                    }
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Available: ${widget.available}',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .headline6!
                                .color!
                                .withOpacity(0.3),
                          ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
