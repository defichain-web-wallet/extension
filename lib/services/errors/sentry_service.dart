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
        options.dsn = 'https://ebedfe3e227aff134bb53f684ab7e4c6@o4505679900901376.ingest.sentry.io/4505682134827008';
        options.tracesSampleRate = 1.0;
      },
    );
  }
}
