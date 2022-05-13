import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry/sentry.dart';

class LoggerService {
  static invokeInfoLogg(action) async {
    await Sentry.captureMessage(action);
  }
}