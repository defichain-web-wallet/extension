import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class CustomSelectTile extends StatefulWidget {
  final bool isSelected;
  final Widget body;
  final Function() callback;

  const CustomSelectTile({
    Key? key,
    required this.body,
    required this.callback,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<CustomSelectTile> createState() => _CustomSelectTileState();
}

class _CustomSelectTileState extends State<CustomSelectTile> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.callback();
        },
        child: Container(
          padding: EdgeInsets.only(
            top: 19,
            bottom: 23,
            left: 14,
            right: 20,
          ),
          // height: 30,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.8),
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).selectedRowColor.withOpacity(0.24),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 2,),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? null
                          : Theme.of(context).dividerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      gradient:
                          widget.isSelected ? gradientBottomToUpCenter : null,
                    ),
                    child: Center(
                      child: Container(
                        width: widget.isSelected ? 8 : 12,
                        height: widget.isSelected ? 8 : 12,
                        decoration: BoxDecoration(
                          color: isDarkTheme()
                              ? DarkColors.scaffoldBgColor
                              : LightColors.scaffoldContainerBgColor,
                          borderRadius:
                              BorderRadius.circular(widget.isSelected ? 4 : 6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 7.2,
              ),
              Expanded(
                child: widget.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
