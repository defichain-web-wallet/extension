import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonAssetCardContent extends StatelessWidget {
  const SkeletonAssetCardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 69.0,
                  height: 6.0,
                  child: Shimmer.fromColors(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
                SizedBox(height: 16.0,),
                SizedBox(
                  width: 37.0,
                  height: 6.0,
                  child: Shimmer.fromColors(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 37.0,
                  height: 6.0,
                  child: Shimmer.fromColors(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
                SizedBox(height: 16.0,),
                SizedBox(
                  width: 25.0,
                  height: 6.0,
                  child: Shimmer.fromColors(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      baseColor: Color(0xFFD0CDD4),
                      highlightColor: Color(0xFFE0DDE4)),
                ),
              ],
            ),
          ],
        ),
      )
    ;
  }
}
