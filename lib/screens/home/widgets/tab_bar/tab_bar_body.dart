import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/screens/history/history.dart';
import 'package:defi_wallet/screens/home/widgets/asset_list.dart';
import 'package:defi_wallet/screens/home/widgets/transaction_history.dart';
import 'package:defi_wallet/screens/tokens/search_token.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class TabBarBody extends StatelessWidget {
  final TabController? tabController;
  final bool isEmptyList;

  const TabBarBody({
    Key? key,
    this.tabController,
    required this.isEmptyList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            Expanded(child: AssetList()),
            if (!SettingsHelper.isBitcoin())
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextButton(
                  child: Text(
                    ' +  Add token ',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  onPressed: () async {
                    await lockHelper.provideWithLockChecker(
                        context,
                        () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        SearchToken(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ));
                  },
                ),
              ),
          ],
        ),
        Column(
          children: [
            Expanded(child: TransactionHistory()),
            isEmptyList
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: TextButton(
                      child: Text(
                        'More history',
                        style:
                            AppTheme.defiUnderlineText.apply(fontSizeDelta: 4),
                      ),
                      onPressed: () async {
                        await lockHelper.provideWithLockChecker(
                          context,
                          () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  History(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container()
          ],
        ),
      ],
      controller: tabController,
    );
  }
}
