import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

    Get.offAll(() => const MainScreen(), binding: MainBinding());
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
