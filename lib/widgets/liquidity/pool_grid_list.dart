import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_select_pool.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/widgets/liquidity/pool_asset_pair.dart';
import 'package:flutter/material.dart';

class PoolGridList extends StatelessWidget {
  final List<LmPoolModel>? tokensPairs;
  final bool? isFullSize;

  const PoolGridList({Key? key, this.tokensPairs, this.isFullSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: tokensPairs!.length > 0 ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemCount: tokensPairs!.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  NavigatorService.push(context, LiquiditySelectPool(
                    assetPair: tokensPairs![index],
                  ));
                },
                child: PoolAssetPair(
                  assetPair: tokensPairs![index],
                  isGrid: isFullSize!,
                ),
              );
            },
          ) : Center(
            child: Text(
              'No match found',
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .apply(color: Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }
}
