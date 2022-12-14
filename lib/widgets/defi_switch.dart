import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class DefiSwitch extends StatefulWidget {
  bool isEnable;
  DefiSwitch({Key? key, this.isEnable = false}) : super(key: key);

  @override
  State<DefiSwitch> createState() => _DefiSwitchState();
}

class _DefiSwitchState extends State<DefiSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 24,
      decoration: BoxDecoration(
        gradient: widget.isEnable ? gradientBottomToUpCenter : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: FlutterSwitch(
        width: 48,
        height: 24,
        toggleSize: 19,
        padding: 2.5,
        inactiveColor: AppColors.toogleBgLight.withOpacity(0.2),
        activeColor: Colors.transparent,
        value: widget.isEnable,
        onToggle: (bool value) {
          setState(() {
            widget.isEnable = value;
          });
        },
      ),
    );
  }
}
