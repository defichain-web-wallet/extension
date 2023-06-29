import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_select_pool.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/liquidity/pool_asset_pair.dart';
import 'package:defi_wallet/widgets/liquidity/search_pool_pair_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChoosePoolPairScreen extends StatefulWidget {
  const ChoosePoolPairScreen({Key? key}) : super(key: key);

  @override
  State<ChoosePoolPairScreen> createState() => _ChoosePoolPairScreenState();
}

class _ChoosePoolPairScreenState extends State<ChoosePoolPairScreen>
    with ThemeMixin {
  TextEditingController searchController = new TextEditingController();
  String titleText = 'Choose pool pair';
  bool filter = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
      LmCubit lmCubit = BlocProvider.of<LmCubit>(context);

                return Scaffold(
                  drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                  endDrawer: isFullScreen ? null : AccountDrawer(
                    width: buttonSmallWidth,
                  ),
                  appBar: isFullScreen ? null : NewMainAppBar(
                    isShowLogo: false,
                    callback: ()=>lmCubit.search(''),
                  ),
                  body: Container(
                    padding: EdgeInsets.only(
                      top: 22,
                      bottom: 0,
                      left: 16,
                      right: 16,
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkTheme()
                          ? DarkColors.drawerBgColor
                          : LightColors.scaffoldContainerBgColor,
                      border: isDarkTheme()
                          ? Border.all(
                              width: 1.0,
                              color: Colors.white.withOpacity(0.05),
                            )
                          : null,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                        bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                      ),
                    ),
                    child: Center(
                      child: StretchBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText,
                              style: headline2.copyWith(
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SearchPoolPairField(
                                  controller: searchController,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      filter
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  filter = !filter;
                                                });
                                              },
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: SvgPicture.asset(
                                                  'assets/icons/grid_view.svg',
                                                  color: isDarkTheme()
                                                      ? AppColors.white
                                                      : null,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  filter = !filter;
                                                });
                                              },
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: SvgPicture.asset(
                                                  'assets/icons/list_bullets.svg',
                                                  color: isDarkTheme()
                                                      ? AppColors.white
                                                      : null,
                                                ),
                                              ),
                                            ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: filter ? 13 : 16,
                            ),
                            if (filter)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 70,
                                    child: Text(
                                      'Pair',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: 97,
                                    child: Text(
                                      'Composition',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    child: Text(
                                      'Yield',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: 91,
                                    child: Text(
                                      'Total',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                       BlocBuilder<LmCubit, LmState>(
                  builder: (lmContext, lmState) =>
                             Expanded(
                              child: lmState.foundedPools!.length > 0
                                  ? !filter
                                      ? GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 160,
                                            childAspectRatio: 0.95,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemCount: lmState.foundedPools!.length,
                                          itemBuilder:
                                              (BuildContext ctx, index) {
                                            return InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () async {
                                                NavigatorService.push(
                                                  context,
                                                  LiquiditySelectPool(
                                                    assetPair:
                                                    lmState.foundedPools![
                                                    index],
                                                  ),
                                                );
                                              },
                                              child: PoolAssetPair(
                                                assetPair:
                                                lmState.foundedPools![index],
                                                isGrid: true,
                                              ),
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          itemCount: lmState.foundedPools!.length,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          itemBuilder:
                                              (BuildContext ctx, index) {
                                            return Column(
                                              children: [
                                                InkWell(
                                                  highlightColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  splashColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    NavigatorService.push(context,
                                                        LiquiditySelectPool(
                                                          assetPair: lmState.foundedPools![
                                                          index]
                                                      ),
                                                    );
                                                  },
                                                  child: PoolAssetPair(
                                                    assetPair:
                                                    lmState.foundedPools![index],
                                                    isGrid: false,
                                                  ),
                                                ),
                                                if (!((lmState.foundedPools!.length -
                                                        1) ==
                                                    index))
                                                  Divider(
                                                    height: 1,
                                                    color: Theme.of(context)
                                                        .dividerColor
                                                        .withOpacity(0.16),
                                                  )
                                              ],
                                            );
                                          },
                                        )
                                  : Center(
                                      child: Text(
                                        'No match found',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .apply(color: Colors.grey.shade600),
                                      ),
                                    ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
    );
  }
}
