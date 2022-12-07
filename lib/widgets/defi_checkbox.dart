import 'package:flutter/material.dart';

class DefiCheckbox extends StatefulWidget {
  String text;
  double textWidth;
  bool value;
  Widget textWidget;
  Function? callback;

  DefiCheckbox({
    Key? key,
    this.callback,
    this.text = '',
    this.textWidth = 300,
    this.value = false,
    this.textWidget = const Text('Add your text')
  }) : super(key: key);

  @override
  State<DefiCheckbox> createState() => _DefiCheckboxState();
}

class _DefiCheckboxState extends State<DefiCheckbox> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          mainAxisAlignment: MainAxisAlignment.center,
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
                splashRadius: 1,
                side: BorderSide(
                  color: Colors.transparent,
                ),
                focusColor: Colors.transparent,
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
            Container(
              width: widget.textWidth,
              child: widget.textWidget,
            ),
          ],
        ),
      ),
    );
  }
}

