import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ListEntry extends StatelessWidget {
  final String iconUrl;
  final String label;
  final Function() callback;
  final bool disabled;

  const ListEntry({
    Key? key,
    required this.iconUrl,
    required this.label,
    required this.callback,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    return ListTile(
      onTap: () async {
        if (!disabled) {
          await callback();
          await tokensCubit.loadTokensFromStorage();
          await tokensCubit.loadTokens();
        }
      },
      contentPadding: const EdgeInsets.only(left: 60),
      leading: SvgPicture.asset(
        iconUrl,
        height: 24,
        width: 24,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.headline4!.apply(
            color: disabled ? Theme
                .of(context)
                .secondaryHeaderColor : Theme
                .of(context)
                .textTheme
                .headline4!
                .color
        ),
      ),
    );
  }
}
