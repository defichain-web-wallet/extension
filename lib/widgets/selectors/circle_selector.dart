import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:flutter/material.dart';

class CircleSelector extends StatefulWidget {
  final Function() callback;
  final bool isSelect;

  const CircleSelector(
      {Key? key, required this.callback, this.isSelect = false})
      : super(key: key);

  @override
  State<CircleSelector> createState() => _CircleSelectorState();
}

class _CircleSelectorState extends State<CircleSelector> with ThemeMixin {
  String selectedPath = 'assets/images/selected_circle_selector.png';
  String darkPath = 'assets/images/dark_circle_selector.png';
  String lightPath = 'assets/images/light_circle_selector.png';
  late String imgPath;

  @override
  void initState() {
    imgPath = widget.isSelect
        ? selectedPath
        : isDarkTheme()
            ? darkPath
            : lightPath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.callback,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(
          imgPath,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
