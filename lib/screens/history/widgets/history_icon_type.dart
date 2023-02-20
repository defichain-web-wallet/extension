import 'package:defi_wallet/screens/history/widgets/icon_history_type.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class HistoryIconType extends StatelessWidget {
  final String type;

  const HistoryIconType({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: historyTypeIconGradient,
      ),
      child: IconHistoryType(
        type: type,
      ),
    );
  }
}
