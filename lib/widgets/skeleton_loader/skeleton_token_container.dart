import 'package:defi_wallet/widgets/skeleton_loader/skeleton_container.dart';
import 'package:flutter/material.dart';

class SkeletonTokenContainer extends StatefulWidget {
  final Color? color;

  SkeletonTokenContainer({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  State<SkeletonTokenContainer> createState() => _SkeletonTokenContainerState();
}

class _SkeletonTokenContainerState extends State<SkeletonTokenContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
          ),
          SkeletonContainer(
            width: 40,
            height: 40,
            color: widget.color,
            shape: BoxShape.circle,
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              SkeletonContainer(
                width: 125,
                height: 12,
                color: widget.color,
                borderRadius: BorderRadius.circular(8),
              ),
              SizedBox(
                height: 8,
              ),
              SkeletonContainer(
                width: 40,
                height: 8,
                color: widget.color,
                borderRadius: BorderRadius.circular(8),
              )
            ],
          ),
        ],
      ),
    );
  }
}
