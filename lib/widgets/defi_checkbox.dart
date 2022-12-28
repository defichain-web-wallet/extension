import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class DefiCheckbox extends StatefulWidget {
  final String text;
  final double width;
  bool value;
  bool isFocused;
  final bool isShowLabel;
  final Widget textWidget;
  final Function(bool? val)? callback;
  FocusNode? focusNode;

  DefiCheckbox(
      {Key? key,
      this.callback,
      this.focusNode,
      this.isFocused = false,
      this.text = '',
      this.width = 320,
      this.value = false,
      this.isShowLabel = true,
      this.textWidget = const Text('Add your text')})
      : super(key: key);

  @override
  State<DefiCheckbox> createState() => _DefiCheckboxState();
}

class _DefiCheckboxState extends State<DefiCheckbox> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              widget.callback!(!widget.value);
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 1,
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: widget.value ? gradientButton : null,
                  borderRadius: BorderRadius.circular(6),
                  border: !widget.value
                      ? Border.all(
                          color: AppColors.darkTextColor.withOpacity(0.10),
                          width: 2,
                        )
                      : null,
                ),
                child: Checkbox(
                  focusNode: widget.focusNode,
                  splashRadius: 16,
                  side: BorderSide(
                    color: Colors.transparent,
                  ),
                  activeColor: Colors.transparent,
                  value: widget.value,
                  onChanged: (val) {
                    widget.callback!(val);
                  },
                ),
              ),
              if (!widget.isShowLabel)
                SizedBox(
                  width: 14,
                ),
              if (!widget.isShowLabel)
                Expanded(
                  child: widget.textWidget,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
