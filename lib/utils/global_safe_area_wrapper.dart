import 'dart:io';

import 'package:atlas/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalSafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const GlobalSafeAreaWrapper({
    super.key,
    required this.child,
    this.top = false,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getSystemUiOverlayStyle(context),
      child: SafeArea(
        top: top,
        // bottom: Platform.isAndroid ? true : false,
        bottom: true,
        left: left,
        right: right,
        child: child,
      ),
    );
  }

  SystemUiOverlayStyle _getSystemUiOverlayStyle(BuildContext context) {
    return SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
