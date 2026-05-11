import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalSafeAreaWrapper extends StatelessWidget {
  final Widget child;
  const GlobalSafeAreaWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.black, // Reverted to dark background
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
