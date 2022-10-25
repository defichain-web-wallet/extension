import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPoolPairField extends StatefulWidget {
  final TextEditingController controller;
  final TokensState tokensState;

  const SearchPoolPairField(
      {Key? key, required this.controller, required this.tokensState})
      : super(key: key);

  @override
  State<SearchPoolPairField> createState() => _SearchPoolPairFieldState();
}

class _SearchPoolPairFieldState extends State<SearchPoolPairField> {
  @override
  Widget build(BuildContext context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    return StretchBox(
      maxWidth: 300,
      minWidth: 150,
      child: Container(
        padding: const EdgeInsets.only(top: 6),
        height: 40,
        child: TextField(
          cursorHeight: 10,
          style: Theme.of(context).textTheme.headline4,
          textAlignVertical: TextAlignVertical.center,
          controller: widget.controller,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.pinkColor),
            ),
            isDense: true,
            hintText: 'Search for pool pairs',
            prefixIcon: Icon(
              Icons.search,
              size: 14,
            ),
            contentPadding: const EdgeInsets.only(top: 4, right: 16),
          ),
          onChanged: (value) async {
            tokensCubit.search(widget.tokensState.tokens, value);
          },
        ),
      ),
    );
  }
}
