import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class TabBarHeader extends StatefulWidget {
  final TabController? tabController;
  final double width;

  const TabBarHeader({
    Key? key,
    this.tabController,
    this.width = 150,
  }) : super(key: key);

  @override
  State<TabBarHeader> createState() => _TabBarHeaderState();
}

class _TabBarHeaderState extends State<TabBarHeader> {
  @override
  Widget build(BuildContext context) => Container(
        width: widget.width,
        height: 38,
        child: Ink(
          child: TabBar(
            labelStyle: Theme.of(context).textTheme.headline6,
            unselectedLabelColor:
                Theme.of(context).textTheme.headline1!.color!.withOpacity(0.6),
            labelColor: Theme.of(context).textTheme.headline1!.color,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: AppTheme.pinkColor,
              ),
              insets: EdgeInsets.symmetric(
                horizontal: widget.width * 0.3,
              ),
            ),
            tabs: [
              Tab(text: 'Assets'),
              Tab(text: 'History'),
            ],
            controller: widget.tabController,
          ),
        ),
      );
}
