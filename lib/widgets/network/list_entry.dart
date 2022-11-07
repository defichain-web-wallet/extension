import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ListEntry extends StatelessWidget {
  final String? iconUrl;
  final String label;
  final Function() callback;
  final bool disabled;
  final bool updateTokens;

  const ListEntry({
    Key? key,
    this.iconUrl,
    required this.label,
    required this.callback,
    this.disabled = false,
    this.updateTokens = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: ListTile(
        style: ListTileStyle.list,
        onTap: () async {
          if (!disabled) {
            await callback();
            if (updateTokens) {
              await tokensCubit.loadTokensFromStorage();
            }
          }
        },
        contentPadding: EdgeInsets.only(left: (iconUrl != null) ? 60 : 0),
        leading: (iconUrl != null)
            ? Opacity(
                opacity: disabled ? 0.3 : 1,
                child: SvgPicture.asset(
                  iconUrl!,
                  height: 24,
                  width: 24,
                ),
              )
            : null,
        title: Text(
          label,
          textAlign: iconUrl == null ? TextAlign.center : null,
          style: Theme.of(context).textTheme.headline3!.apply(
              color: disabled
                  ? Color(0xFF7D7D7D)
                  : Theme.of(context).textTheme.headline3!.color),
        ),
      ),
    );
  }
}
