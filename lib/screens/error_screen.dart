import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart';
import 'dart:js' as js;

class ErrorScreen extends StatefulWidget {
  final FlutterErrorDetails? errorDetails;

  const ErrorScreen({
    Key? key,
    this.errorDetails,
  }) : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {

  @override
  initState() {
    super.initState();
    document.onContextMenu.listen((event) => event.preventDefault());
  }

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      final overlay =
      Overlay
          .of(context)
          .context
          .findRenderObject() as RenderBox;
      final menuItem = await showMenu<int>(
          context: context,
          items: [
            PopupMenuItem(child: Text('Recovery'), value: 1),
            PopupMenuItem(child: Text('Inspect'), value: 2),
          ],
          position: RelativeRect.fromSize(
              event.position & Size(48.0, 48.0), overlay.size));
      // Check if menu item clicked
      switch (menuItem) {
        case 1:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Copy clicked'),
            behavior: SnackBarBehavior.floating,
          ));
          break;
        case 2:
          {
            print(1);
            js.context.callMethod('open', ['chrome://inspect/']);
          }
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: _onPointerDown,
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(
              top: 44,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Image.asset('assets/images/jelly_oops.png'),
                    ),
                    Text(
                      'Oops!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                                'Something went wrong, it looks like API is not responding. Please, report the issue ',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.6),
                                    ),
                          ),
                          TextSpan(
                              text: 'here',
                              style:
                                  Theme.of(context).textTheme.headline5!.copyWith(
                                        decoration: TextDecoration.underline,
                                        color: AppColors.pinkColor,
                                      ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => launch(
                                  JellyLinks.telegramGroup,
                                )),
                          TextSpan(
                            text: ' and try again later.',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.6),
                                    ),
                          ),
                        ]))
                  ],
                ),
                NewPrimaryButton(
                  title: 'Go back',
                  callback: () => Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          HomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
