import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SuffixTypes { password }

class SuffixIcon extends StatefulWidget {
  final SuffixTypes suffixType;
  final Function() callback;
  final bool isObscure;
  final bool isOpasity;

  const SuffixIcon({
    Key? key,
    required this.callback,
    this.suffixType = SuffixTypes.password,
    this.isObscure = false,
    this.isOpasity = false,
  }) : super(key: key);

  @override
  State<SuffixIcon> createState() => _SuffixIconState();
}

class _SuffixIconState extends State<SuffixIcon> {
  @override
  Widget build(BuildContext context) {
    if (widget.suffixType == SuffixTypes.password) {
      String iconUrl = widget.isObscure
          ? 'assets/icons/visibility_off.svg'
          : 'assets/icons/visibility.svg';

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.callback,
          child: SvgPicture.asset(
            iconUrl,
            width: 16,
            height: 16,
            color:
                widget.isOpasity ? Theme.of(context).textTheme.headline1!.color! : Theme.of(context).textTheme.headline1!.color!.withOpacity(0.6),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}