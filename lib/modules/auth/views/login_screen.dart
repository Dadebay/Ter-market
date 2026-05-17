import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginScreen extends StatefulWidget {
  final bool fromProfile;
  const LoginScreen({super.key, this.fromProfile = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      setState(() => _error = 'empty_fields'.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate login — replace with real API call when backend /auth endpoint is ready
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Color(0xff22B241),
            size: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xff22B241).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: Color(0xff22B241),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'login_title'.tr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Gilroy',
                  color: Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'login_instruction'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _InputField(
                controller: _phoneController,
                hint: 'phone_number_label'.tr,
                icon: HugeIcons.strokeRoundedCall,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _InputField(
                controller: _passwordController,
                hint: 'password_label'.tr,
                icon: HugeIcons.strokeRoundedLockPassword,
                obscureText: _obscurePassword,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: HugeIcon(
                    icon: _obscurePassword ? HugeIcons.strokeRoundedEye : HugeIcons.strokeRoundedViewOff,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff22B241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'login_button'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6ECE8)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: HugeIcon(icon: icon, color: Colors.grey, size: 20),
          ),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
