import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeeCard extends StatelessWidget {
  final String iconUrl;
  final String label;
  final int fee;
  final bool isActive;
  final Function() callback;

  const FeeCard({
    Key? key,
    required this.fee,
    required this.iconUrl,
    required this.label,
    required this.callback,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColorLight
                : Colors.transparent),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: callback,
          child: ListTile(
            minLeadingWidth: 20,
            leading: SvgPicture.asset(iconUrl, width: 20, height: 20,),
            title: Text(label),
            trailing: Text('$fee sat pro byte'),
          ),
        ),
      ),
    );
  }
}
