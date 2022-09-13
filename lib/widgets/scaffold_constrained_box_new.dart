import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';

class ScaffoldConstrainedBoxNew extends StatefulWidget {
  final child;
  final appBar;
  final Function()? hideOverlay;

  const ScaffoldConstrainedBoxNew({Key? key, this.child, this.appBar, this.hideOverlay}) : super(key: key);



  @override
  State<ScaffoldConstrainedBoxNew> createState() => _ScaffoldConstrainedBoxState();
}

class _ScaffoldConstrainedBoxState extends State<ScaffoldConstrainedBoxNew> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ScreenSizes.medium),
          child: GestureDetector(
            onTap: () => widget.hideOverlay,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: widget.appBar,
                    body: Container(
                      color: null,
                      padding:
                      const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
                      child: Center(
                        child: StretchBox(
                          child: widget.child,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: widget.appBar,
                      body: Container(
                        color: Theme.of(context).dialogBackgroundColor,
                        padding:
                        const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
                        child: Center(
                          child: StretchBox(
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
