import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class SelectorThemeElement extends StatefulWidget {
  final bool isSelected;
  final Function() callback;
  final String text;
  final double width;
  final double height;

  const SelectorThemeElement({
    Key? key,
    required this.isSelected,
    required this.callback,
    required this.text,
    this.width = 328,
    this.height = 61,
  }) : super(key: key);

  @override
  State<SelectorThemeElement> createState() => _SelectorThemeElementState();
}

class _SelectorThemeElementState extends State<SelectorThemeElement> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.callback();
        },
        child: Container(
          padding: EdgeInsets.all(1),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isSelected ? null : AppColors.noSelectLight1,
            gradient: widget.isSelected ? gradientBottomToUpCenter : null,
          ),
          child: Center(
            child: Container(
              width: widget.width - 2,
              height: widget.height - 2,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected ? null : AppColors.noSelectLight2,
                      borderRadius: BorderRadius.circular(8),
                      gradient:
                          widget.isSelected ? gradientBottomToUpCenter : null,
                    ),
                    child: Center(
                      child: Container(
                        width: widget.isSelected ? 8 : 12,
                        height: widget.isSelected ? 8 : 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius:
                              BorderRadius.circular(widget.isSelected ? 4 : 6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 13,
                  ),
                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
