import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SuffixTypes { password }

class SuffixIcon extends StatefulWidget {
  final SuffixTypes suffixType;
  final Function() callback;
  final bool isObscure;

  const SuffixIcon({
    Key? key,
    required this.callback,
    this.suffixType = SuffixTypes.password,
    this.isObscure = false,
  }) : super(key: key);

  @override
  State<SuffixIcon> createState() => _SuffixIconState();
}

class _SuffixIconState extends State<SuffixIcon> {
  @override
  Widget build(BuildContext context) {
    print('suffix icon');
    if (widget.suffixType == SuffixTypes.password) {
      String iconUrl = widget.isObscure
          ? 'assets/icons/visibility_off.svg'
          : 'assets/icons/visibility.svg';

      return GestureDetector(
        onTap: widget.callback,
        child: SvgPicture.asset(
          iconUrl,
          width: 24,
          height: 24,
        ),
      );
    } else {
      return Container();
    }
  }
}