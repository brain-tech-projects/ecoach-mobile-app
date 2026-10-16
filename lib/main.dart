

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecoach_pro/app/app.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Central error reporting. Plug Crashlytics / Sentry in here later.
  FlutterError.onError = (FlutterErrorDetails details) {  
    FlutterError.presentError(details);
    AppLogger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error(
      'Uncaught async error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  // Phones are portrait-only (matches the web design).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final storage = await LocalStorage.create();

  if (kDebugMode) {
    AppLogger.debug('Booting eCoach Pro');
  }

  runApp(EcoachApp(storage: storage));
}