import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:atlas/themes/colors.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;

  const PaymentWebViewScreen({super.key, required this.url});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _closed = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (!mounted) return;
          setState(() => _isLoading = true);
          _checkAndClose(url);
        },
        onPageFinished: (url) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _checkAndClose(url);
        },
        onNavigationRequest: (request) {
          _checkAndClose(request.url);
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkAndClose(String url) {
    if (_closed) return;
    final isActivateOrder = url.contains('activate-order') || url.contains('activate_order');
    if (isActivateOrder) {
      _closed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          '',
          style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }
}
