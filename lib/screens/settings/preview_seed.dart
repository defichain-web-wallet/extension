import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/text_fields.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';

class PreviewSeed extends StatefulWidget {
  final List<String> mnemonic;
  const PreviewSeed({Key? key, required this.mnemonic}) : super(key: key);

  @override
  State<PreviewSeed> createState() => _PreviewSeedState();
}

class _PreviewSeedState extends State<PreviewSeed> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  List<int> invalidControllerIndexes = [];
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
        widget.mnemonic.length, (i) => TextEditingController(text: widget.mnemonic[i]));
    focusNodes = List.generate(widget.mnemonic.length, (i) => FocusNode());
  }

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
    focusNodes.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldConstrainedBox(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < ScreenSizes.medium) {
          return Scaffold(
            appBar: MainAppBar(
                title: 'Seed'
            ),
            body: _buildBody(context),
          );
        } else {
          return Container(
            padding: EdgeInsets.only(top: 20),
            child: Scaffold(
              appBar: MainAppBar(
                title: 'Seed',
                isSmall: true,
              ),
              body: _buildBody(context, isFullSize: true),
            ),
          );
        }
      }),
    );
  }

  Widget _buildBody(context, {isFullSize = false}) {
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: StretchBox(
            child: Column(
              children: [
                Text(
                  'Recovery seed',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(
                  height: 12,
                ),
                TextFields(
                  controllers: controllers,
                  focusNodes: focusNodes,
                  globalKey: globalKey,
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
