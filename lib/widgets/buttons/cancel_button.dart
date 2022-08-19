import 'package:defi_wallet/helpers/router_helper.dart';
import 'package:defi_wallet/utils/routes.dart';
import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final Function()? callback;

  const CancelButton({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RouterHelper routerHelper = RouterHelper();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        iconSize: 20,
        splashRadius: 18,
        icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
        onPressed: callback ?? () async {
          await routerHelper.setCurrentRoute(Routes.home);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
