import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InvestedField extends StatefulWidget {
  final TextEditingController? controller;
  final String? subtitle;
  final String tokenName;
  final String label;
  final bool isDeleteBtn;
  final bool isDisable;
  final bool isReinvest;
  final Function(String amount) onChange;
  final Function() onRemove;

  const InvestedField({
    Key? key,
    required this.tokenName,
    required this.label,
    required this.onChange,
    required this.onRemove,
    this.controller,
    this.subtitle,
    this.isDeleteBtn = true,
    this.isDisable = false,
    this.isReinvest = false,
  }) : super(key: key);

  @override
  State<InvestedField> createState() => _InvestedFieldState();
}

class _InvestedFieldState extends State<InvestedField> with ThemeMixin {
  static const int defaultLengthLimit = 2;
  static const int reinvestLengthLimit = 3;

  TokensHelper tokenHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 218,
          padding: const EdgeInsets.only(bottom: 6),
          child: TextFormField(
            controller: widget.controller,
            readOnly: widget.isDisable,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength:
                widget.isReinvest ? reinvestLengthLimit : defaultLengthLimit,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontSize: 16,
                ),
            decoration: InputDecoration(
              filled: !widget.isDisable,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              enabledBorder:
                  Theme.of(context).inputDecorationTheme.enabledBorder,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              counterText: '',
              counterStyle: TextStyle(fontSize: 0),
              contentPadding: EdgeInsets.only(right: 0),
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 0),
                child: Container(
                  width: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '%',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
              prefixIcon: Container(
                width: 144,
                height: 56,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              tokenHelper
                                  .getImageNameByTokenName(widget.tokenName),
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.tokenName} ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 16,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0),
                                  child: Text(
                                    widget.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (widget.subtitle != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 32,
                              ),
                              Text(
                                widget.subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            onChanged: (String value) => widget.onChange(value),
          ),
        ),
        if (widget.isDeleteBtn)
          Container(
            width: 32,
            height: 32,
            child: Center(
              child: NewActionButton(
                onPressed: () {
                  widget.onRemove();
                },
                iconPath: 'assets/icons/cross.svg',
                width: 28,
                height: 28,
              ),
            ),
          ),
      ],
    );
  }
}
