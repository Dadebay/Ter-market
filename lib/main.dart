import 'dart:io';

import 'package:atlas/core/lang/app_translations.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/firebase_options.dart';
import 'package:atlas/firebase_messaging_service.dart';
import 'package:atlas/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/theme/app_theme.dart';
import 'package:atlas/modules/splash/views/splash_screen.dart';
import 'package:atlas/utils/global_safe_area_wrapper.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  await GetStorage.init();
  Get.put(GetStorage());
  Get.put(LanguageController());

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);

  // Set up global token refresh listener for server registration
  _setupFcmTokenListener();

  runApp(const AtlasApp());
}

void _setupFcmTokenListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('[FCM] Token refresh detected: $newToken');
    try {
      final storage = Get.find<GetStorage>();
      await ApiService().registerFcmToken(newToken);
      storage.write('fcm_token', newToken);
      print('[FCM] Token registered successfully via global listener');
    } catch (e) {
      print('[FCM] Failed to register token via global listener: $e');
    }
  });
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
        return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
