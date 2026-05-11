import 'package:atlas/core/lang/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/theme/app_theme.dart';
import 'package:atlas/modules/main/bindings/main_binding.dart';
import 'package:atlas/modules/main/views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const AtlasApp());
}

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: const Locale('tk', 'TM'),
      fallbackLocale: const Locale('tk', 'TM'),
      initialBinding: MainBinding(),
      home: const MainScreen(),
      defaultTransition: Transition.cupertino,
    );
  }
}
