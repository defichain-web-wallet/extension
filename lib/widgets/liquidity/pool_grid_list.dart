import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/select_pool_screen.dart';
import 'package:defi_wallet/widgets/liquidity/pool_asset_pair.dart';
import 'package:flutter/material.dart';

class PoolGridList extends StatelessWidget {
  final List<AssetPairModel>? tokensPairs;
  final bool? isFullSize;

  const PoolGridList({Key? key, this.tokensPairs, this.isFullSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: tokensPairs!.length > 0
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: tokensPairs!.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemBuilder: (BuildContext ctx, index) {
                    return InkWell(
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                SelectPoolScreen(
                              assetPair: tokensPairs![index],
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: PoolAssetPair(
                        assetPair: tokensPairs![index],
                        isFullSize: isFullSize!,
                      ),
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
        ),
      ],
    );
  }
}
