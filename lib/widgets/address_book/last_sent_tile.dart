import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class LastSentTile extends StatefulWidget {
  const LastSentTile({Key? key}) : super(key: key);

  @override
  State<LastSentTile> createState() => _LastSentTileState();
}

class _LastSentTileState extends State<LastSentTile> {
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
              '193767erut646ee23e3mfnh3ur3fasdasdasddd4',
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
              SizedBox(width: 15,),
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
