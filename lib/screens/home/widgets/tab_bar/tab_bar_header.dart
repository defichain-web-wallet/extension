import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';

class TabBarHeader extends StatefulWidget {
  final int currentTabIndex;
  final TabController? tabController;

  const TabBarHeader({
    Key? key,
    required this.currentTabIndex,
    this.tabController,
  }) : super(key: key);

  @override
  State<TabBarHeader> createState() => _TabBarHeaderState();
}

class _TabBarHeaderState extends State<TabBarHeader> {
  @override
  Widget build(BuildContext context) => Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            SelectorTabElement(
              callback: () {
                widget.tabController!.index = 0;
              },
              title: 'Assets',
              isSelect: widget.tabController!.index == 0,
            ),
            SizedBox(
              width: 24,
            ),
            SelectorTabElement(
              callback: () {
                widget.tabController!.index = 1;
              },
              title: 'History (Beta)',
              isSelect: widget.tabController!.index == 1,
            )
          ],
        ),
      );
}
