import 'package:defi_wallet/my_app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();

  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options.dsn = "";
      //'https://13eea5580f3541d7aed98ce3c9bbe835@o1163199.ingest.sentry.io/6251231';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(App()),
  );
}
