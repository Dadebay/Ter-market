import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/admin/admin_api_service.dart';
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

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);

  await _registerAdminDevice();

  runApp(const AdminApp());
}

Future<void> _registerAdminDevice() async {
  try {
    final storage = Get.find<GetStorage>();
    var deviceId = storage.read<String>('device_id');
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'atlas-admin-${DateTime.now().millisecondsSinceEpoch}';
      storage.write('device_id', deviceId);
    }

    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    print('[Admin] Registering device: $deviceId, fcmToken: $fcmToken');
    await AdminApiService().registerAdminDevice(deviceId, fcmToken: fcmToken);
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
      home: const AdminOrdersScreen(),
      defaultTransition: Transition.cupertino,
      builder: (context, child) {
        return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
