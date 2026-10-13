import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/bindings/initial_binding.dart';
import 'package:ecoach_pro/app/routes/app_pages.dart';
import 'package:ecoach_pro/core/constants/app_strings.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/core/theme/app_theme.dart';

class EcoachApp extends StatelessWidget {
  const EcoachApp({super.key, required this.storage});

  final LocalStorage storage;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialBinding: InitialBinding(storage),
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          // Respect accessibility font scaling, but keep layouts intact.
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.systemOverlay,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}