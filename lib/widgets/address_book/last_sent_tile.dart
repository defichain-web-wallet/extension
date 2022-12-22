import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class LastSentTile extends StatefulWidget {
  final String address;

  const LastSentTile({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<LastSentTile> createState() => _LastSentTileState();
}

class _LastSentTileState extends State<LastSentTile> {
  
  cutAddress(String s) {
    return s.substring(0, 14) + '...' + s.substring(28, 42);
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 12.8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              cutAddress(widget.address),
              style: headline5.copyWith(
                fontSize: 13,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: AppColors.darkTextColor.withOpacity(0.5),
              ),
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.close,
                size: 16,
                color: AppColors.darkTextColor.withOpacity(0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
