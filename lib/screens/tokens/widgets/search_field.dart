import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchField extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String value)? onChanged;
  final bool isBorder;

  const SearchField({
    Key? key,
    this.controller,
    this.onChanged,
    this.isBorder = false,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  bool isPinkIcon = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(() { });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _focusNode.requestFocus();
        widget.controller!.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.controller!.text.length);
      },
      child: Container(
        height: 46,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.transparent,
          ),
        ),
        child: Focus(
          onFocusChange: (focused) {
            setState(() {
              isPinkIcon = focused;
            });
          },
          child: TextField(
            focusNode: _focusNode,
            textAlignVertical: TextAlignVertical.center,
            style: Theme.of(context).textTheme.button,
            decoration: InputDecoration(
              hintText: 'Search for a token',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hoverColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.button!.decorationColor!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.pinkColor),
              ),
              prefixIcon: Image(
                image: isPinkIcon
                    ? AssetImage('assets/images/search_pink.png')
                    : AssetImage('assets/images/search_gray.png'),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            onChanged: widget.onChanged,
            controller: widget.controller,
          ),
        ),
      ),
    );
  }
}
