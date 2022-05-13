import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class TabBarHeader extends StatelessWidget {
  final TabController? tabController;

  const TabBarHeader({Key? key, this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) => Ink(
        child: TabBar(
          unselectedLabelColor:
              Theme.of(context).textTheme.headline1!.color!.withOpacity(0.6),
          labelColor: AppTheme.pinkColor,
          indicatorColor: AppTheme.pinkColor,
          tabs: [
            Tab(text: 'Assets'),
            Tab(text: 'History'),
          ],
          controller: tabController,
        ),
      );
}
