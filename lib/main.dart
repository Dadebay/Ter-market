import 'package:atlas/core/lang/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/theme/app_theme.dart';
import 'package:atlas/modules/splash/views/splash_screen.dart';
import 'package:atlas/utils/global_safe_area_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(GetStorage());
  runApp(const AtlasApp());
}

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<GetStorage>();
    String langCode = storage.read('langCode') ?? 'tk';

    return GetMaterialApp(
      title: 'Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: Locale(langCode),
      fallbackLocale: const Locale('tk'),
      home: const SplashScreen(),
      defaultTransition: Transition.cupertino,
      builder: (context, child) {
        return GlobalSafeAreaWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
