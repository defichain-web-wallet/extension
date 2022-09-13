import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AccountNameTextForm extends StatefulWidget {
  final String? initValue;
  final void Function(String text)? onConfirm;
  final bool isBorder;

  const AccountNameTextForm({
    Key? key,
    this.initValue,
    this.onConfirm,
    this.isBorder = false,
  }) : super(key: key);

  @override
  _AccountNameTextFormState createState() =>
      _AccountNameTextFormState(this.initValue);
}

class _AccountNameTextFormState extends State<AccountNameTextForm> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  var inputText;
  var showConfirmButton = false;
  var showEditButton = false;

  _AccountNameTextFormState(String? initValue) {
    inputText = initValue;
    _textEditingController.text = inputText;
    _textEditingController.addListener(() {});
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      if (!_focusNode.hasFocus) {
        showConfirmButton = false;
        _textEditingController.text = inputText;
      }
    });
  }

  void _onConfirm() {
    setState(() {
      showConfirmButton = false;
      inputText = _textEditingController.text;
      if (widget.onConfirm != null)
        widget.onConfirm!(_textEditingController.text);
    });
  }

  void _onEdit() => setState(() {
        _focusNode.requestFocus();
        _textEditingController.selection = TextSelection(
            baseOffset: 0, extentOffset: _textEditingController.text.length);
        showConfirmButton = true;
      });

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Material(
        elevation: 5,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {},
          onDoubleTap: () {
            _focusNode.requestFocus();
            _textEditingController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _textEditingController.text.length);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: showConfirmButton
                    ? AppTheme.pinkColor
                    : widget.isBorder
                        ? Theme.of(context).dividerColor
                        : Colors.transparent,
              ),
              color: Theme.of(context).cardColor,
            ),
            child: TextField(
              autofocus: false,
              textAlignVertical: TextAlignVertical.center,
              // style: Theme.of(context).textTheme.button,
              decoration: InputDecoration(
                filled: false,
                fillColor: Theme.of(context).cardColor,
                hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                suffixIcon: showConfirmButton
                    ? IconButton(
                        icon: Icon(Icons.done),
                        iconSize: 20,
                        color: AppTheme.pinkColor,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: _onConfirm,
                      )
                    : (showEditButton
                        ? IconButton(
                            icon: Icon(Icons.edit),
                            iconSize: 18,
                            color: AppTheme.pinkColor,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onPressed: _onEdit,
                          )
                        : null),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              focusNode: _focusNode,
              controller: _textEditingController,
              readOnly: !showConfirmButton,
              onSubmitted: (value) => _onConfirm(),
            ),
          ),
        ),
      ),
      onEnter: (details) {
        setState(() {
          showEditButton = true;
        });
      },
      onExit: (details) {
        setState(() {
          showEditButton = false;
        });
      },
    );
  }
}
