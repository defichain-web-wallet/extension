import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:defi_wallet/models/error/error_model.dart';
import 'package:defi_wallet/my_app.dart';
import 'package:defi_wallet/services/errors/sentry_service.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // await dotenv.load(fileName: '.env');
      await Hive.initFlutter();
      if (kReleaseMode) {
        await SentryService.initSentry();
      }
      runApp(App());
    },
    (exception, stackTrace) async {
      await SentryService.captureException(
        ErrorModel(
          file: 'main.dart',
          method: 'main',
          exception: exception.toString(),
        ),
        stackTrace: stackTrace,
      );
    },
  );
}
