import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class SlippageButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool isPadding;
  final Function() callback;
  final bool isBorder;
  final bool isFirst;
  final bool isLast;

  const SlippageButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.callback,
    this.isPadding = false,
    this.isBorder = false,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  State<SlippageButton> createState() => _SlippageButtonState();
}

class _SlippageButtonState extends State<SlippageButton> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      margin: EdgeInsets.only(left: widget.isPadding ? 8 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: !widget.isActive
              ? DarkColors.slippageBorderColor.withOpacity(0.32)
              : Colors.transparent,
        ),
        gradient: widget.isActive ? gradientSlippageButton : LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.transparent,
          ],
        ),
      ),
      child: TextButton(
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.w600,
                color: widget.isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.headline4!.color,
              ),
        ),
        onPressed: widget.callback,
      ),
    );
  }
}
