import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/shared/no_internet_screen.dart';
import 'package:atlas/modules/main/views/main_screen.dart';
import 'package:atlas/modules/main/bindings/main_binding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _controller.forward();
    _checkStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    bool hasInternet = false;
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      hasInternet = false;
    }

    if (!mounted) return;

    if (!hasInternet) {
      Get.offAll(() => const NoInternetScreen());
      return;
    }

    await _syncFcmToken();
    await _syncDevice();
    Get.offAll(() => const MainScreen(), binding: MainBinding());
  }

  Future<void> _syncFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token == null) return;
      print('[FCM] Current token: $token');

      final storage = Get.find<GetStorage>();
      final stored = storage.read<String>('fcm_token');
      if (stored == token) return;

      await ApiService().registerFcmToken(token);
      storage.write('fcm_token', token);
      print('[FCM] Token registered successfully: $token');

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) async {
        try {
          await ApiService().registerFcmToken(newToken);
          storage.write('fcm_token', newToken);
          print('[FCM] Token refreshed and re-registered: $newToken');
        } catch (e) {
          print('[FCM] Token refresh failed: $e');
        }
      });
    } catch (e) {
      print('[FCM] Registration failed: $e');
    }
  }

  Future<void> _syncDevice() async {
    try {
      final storage = Get.find<GetStorage>();
      var deviceId = storage.read<String>('device_id');
      if (deviceId == null) {
        deviceId = 'atlas-${DateTime.now().millisecondsSinceEpoch}';
        storage.write('device_id', deviceId);
      }

      // Only register once per unique device_id
      final registered = storage.read<String>('device_registered');
      if (registered == deviceId) return;

      await ApiService().registerDevice(deviceId);
      storage.write('device_registered', deviceId);
      print('[Device] Registered successfully: $deviceId');
    } catch (e) {
      print('[Device] Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'app_logo',
              child: Image.asset(
                'assets/images/logo.png',
                width: 420,
                height: 420,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 50,
            right: 50,
            bottom: 100,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final value = _animation.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
