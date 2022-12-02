import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class IbanField extends StatefulWidget {
  final TextEditingController? ibanController;
  final Function(String)? onChanged;
  final Function()? onFocus;
  final String? hintText;
  final String maskFormat;
  final bool isBorder;


  IbanField({
    Key? key,
    this.ibanController,
    this.onChanged,
    this.onFocus,
    this.hintText,
    this.maskFormat = '',
    this.isBorder = false,
  }) : super(key: key);

  @override
  State<IbanField> createState() => _IbanFieldState();
}

class _IbanFieldState extends State<IbanField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(() { });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _maskFormatter;
    String validationRule = 'IBAN';

    if (widget.maskFormat != '') {
      _maskFormatter = [
        new MaskTextInputFormatter(
            mask: widget.maskFormat,
            filter: {
              "A": RegExp(r'[A-Z]'),
              "#": RegExp(r'[0-9]'),
            },
            type: MaskAutoCompletionType.lazy)
      ];
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Your bank account',
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        GestureDetector(
          onDoubleTap: () {
            _focusNode.requestFocus();
            widget.ibanController!.selection = TextSelection(
                baseOffset: 0,
                extentOffset: widget.ibanController!.text.length);
          },
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.transparent)
              ),
              child: Focus(
                onFocusChange: (focused) {
                  if(widget.onFocus != null){
                    widget.onFocus!();
                  }
                },
                child: TextFormField(
                  focusNode: _focusNode,
                  textAlignVertical: TextAlignVertical.center,
                  style: Theme.of(context).textTheme.button,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          top: 12.0, bottom: 12.0, left: 22, right: 22),
                      child: Text(
                        'IBAN',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        padding: EdgeInsets.only(left: 0),
                        splashRadius: 1,
                        icon: GestureDetector(
                          onTap: () {
                            Clipboard.getData(Clipboard.kTextPlain).then((value) {
                              final filter = RegExp(r'[A-Z]{2}[0-9]{20}');
                              if (filter.hasMatch(value!.text!) &&
                                  value.text!.length == 22) {
                                widget.ibanController?.text = value.text!;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                    'Invalid IBAN.',
                                    style: Theme.of(context).textTheme.headline5,
                                  )),
                                );
                              }
                            });
                          },
                          child: SvgPicture.asset('assets/paste_icon.svg'),
                        ),
                        onPressed: () {
                        },
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    hoverColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppTheme.pinkColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    hintText: widget.hintText,
                  ),
                  onChanged: widget.onChanged,
                  controller: widget.ibanController,
                  inputFormatters: _maskFormatter,
                  validator: (value) {
                    switch (validationRule) {
                      case 'IBAN':
                        return value == null || value.isEmpty
                            ? 'Please enter this field'
                            : value != null && value.length < 16
                                ? "Enter 16 characters"
                                : null;
                      default:
                        return value == null || value.isEmpty
                            ? 'Please enter this field'
                            : null;
                    }
                  },
                ),
              )),
        ),
      ],
    );
  }
}
