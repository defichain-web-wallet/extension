import 'package:defi_wallet/widgets/home/skeleton_asset_card_content.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonTransactionHistoryCard extends StatelessWidget {
  const SkeletonTransactionHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(
                bottom: 8, left: 16, right: 16, top: 2),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer.fromColors(
                      child: Container(
                        width: 50.0,
                        height: 6.0,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ]),
          ),
          Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.only(
                  bottom: 8, left: 16, right: 16, top: 2),
              child: SizedBox(height: 10.0)
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(
                bottom: 8, left: 16, right: 16, top: 2),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                  child: Shimmer.fromColors(
                      child: Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
                SkeletonAssetCardContent()
              ],
            ),
          ),
          Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.only(
                  bottom: 8, left: 16, right: 16, top: 2),
              child: SizedBox(height: 10.0)
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(
                bottom: 8, left: 16, right: 16, top: 2),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer.fromColors(
                      child: Container(
                        width: 50.0,
                        height: 6.0,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ]),
          ),
          Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.only(
                  bottom: 8, left: 16, right: 16, top: 2),
              child: SizedBox(height: 10.0)
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(
                bottom: 8, left: 16, right: 16, top: 2),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                  child: Shimmer.fromColors(
                      child: Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
                SkeletonAssetCardContent()
              ],
            ),
          ),
          Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.only(
                  bottom: 8, left: 16, right: 16, top: 2),
              child: SizedBox(height: 10.0)
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(
                bottom: 8, left: 16, right: 16, top: 2),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                  child: Shimmer.fromColors(
                      child: Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
                SkeletonAssetCardContent()
              ],
            ),
          ),
        ]
      ),
    );
  }
}
