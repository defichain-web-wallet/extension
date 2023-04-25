import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class DottedTab extends StatefulWidget {
  final int tabLenth;
  final int selectTabIndex;

  const DottedTab({Key? key, this.tabLenth = 4, this.selectTabIndex = 1})
      : super(key: key);

  @override
  State<DottedTab> createState() => _DottedTabState();
}

class _DottedTabState extends State<DottedTab> with ThemeMixin {
  List<Widget> tabBody = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.tabLenth; i++) {
      if (i == widget.selectTabIndex - 1) {
        tabBody.add(Container(
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: gradientButton,
          ),
        ));
      } else {
        tabBody.add(Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.portage.withOpacity(0.15),
          ),
        ));
      }
      if (i + 1 != widget.tabLenth) {
        tabBody.add(SizedBox(
          width: 6.4,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tabBody,
      ),
    );
  }
}
