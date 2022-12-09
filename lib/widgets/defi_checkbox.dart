import 'package:flutter/material.dart';

class DefiCheckbox extends StatefulWidget {
  final String text;
  final double width;
  bool value;
  bool isFocused;
  final Widget textWidget;
  final Function? callback;
  FocusNode? focusNode;

  DefiCheckbox({
    Key? key,
    this.callback,
    this.focusNode,
    this.isFocused = false,
    this.text = '',
    this.width = 300,
    this.value = false,
    this.textWidget = const Text('Add your text')
  }) : super(key: key);

  @override
  State<DefiCheckbox> createState() => _DefiCheckboxState();
}

class _DefiCheckboxState extends State<DefiCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              widget.value = !widget.value;
              widget.callback!();
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: widget.value
                      ? LinearGradient(
                          colors: [
                            Color(0xFFBC00C0),
                            Color(0xFFFF00A3),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  border: !widget.value
                      ? Border.all(
                          color: Color(0xFFe0dce8),
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
                  onChanged: (bool? val) {
                    setState(() {
                      widget.value = val!;
                      widget.callback!();
                    });
                  },
                ),
              ),
              SizedBox(width: 14,),
              Expanded(
                child: Container(
                  child: widget.textWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

