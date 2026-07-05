import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/admin/admin_api_service.dart';
import 'package:atlas/admin/admin_login_screen.dart';
import 'package:atlas/admin/admin_orders_screen.dart';
import 'package:atlas/core/lang/app_translations.dart';
import 'package:atlas/core/theme/app_theme.dart';
import 'package:atlas/firebase_options.dart';
import 'package:atlas/local_notifications_service.dart';
import 'package:atlas/firebase_messaging_service.dart';
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

  print('[Admin] isLoggedIn=${AdminApiService.isLoggedIn} access=${AdminApiService.accessToken}');

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);

  if (AdminApiService.isLoggedIn) {
    await _registerAdminDevice();
  }

  runApp(const AdminApp());
}

Future<void> _registerAdminDevice() async {
  try {
    await FirebaseMessaging.instance.requestPermission();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      print('[Admin] FCM token null, onTokenRefresh dinleniyor');
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        print('[Admin] onTokenRefresh: $token');
        try {
          await AdminApiService().registerAdminDevice(token);
        } catch (e) {
          print('[Admin] onTokenRefresh registration failed: $e');
        }
      });
      return;
    }
    print('[Admin] FCM token: $fcmToken');
    await AdminApiService().registerAdminDeviwce(fcmToken);
    print('[Admin] Device registered successfully');
  } catch (e) {
    print('[Admin] Device registration failed (non-fatal): $e');
  }
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ter Market Orders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: const Locale('tk'),
      fallbackLocale: const Locale('tk'),
      home: () {
        final loggedIn = AdminApiService.isLoggedIn;
        print('[Admin] home decision: loggedIn=$loggedIn -> ${loggedIn ? 'AdminOrdersScreen' : 'AdminLoginScreen'}');
        return loggedIn ? const AdminOrdersScreen() : const AdminLoginScreen();
      }(),
      defaultTransition: Transition.cupertino,
      builder: (context, child) {
        return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
