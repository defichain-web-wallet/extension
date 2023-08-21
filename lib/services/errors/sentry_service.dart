import 'package:defi_wallet/models/error/error_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static captureException(
    ErrorModel errorModel, {
    dynamic stackTrace,
  }) async {
    await Sentry.captureException(
      errorModel.toJSON(),
      stackTrace: stackTrace,
    );
  }

  static captureMessage(
    ErrorModel errorModel,
  ) async {
    await Sentry.captureMessage(
      errorModel.toJSON().toString(),
    );
  }

  static Future initSentry() async {
    SentryFlutter.init(
      (options) {
        options.dsn = dotenv.env['SENTRY_DSN']!;
        options.tracesSampleRate = 1.0;
      },
    );
  }
}
