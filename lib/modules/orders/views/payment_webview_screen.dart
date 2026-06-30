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
    // ignore: avoid_print
    print('\x1B[35m┌─── PAYMENT WEBVIEW INIT ──────────────────────\x1B[0m');
    // ignore: avoid_print
    print('\x1B[35m│ url: ${widget.url}\x1B[0m');
    // ignore: avoid_print
    print('\x1B[35m└───────────────────────────────────────────────\x1B[0m');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          // ignore: avoid_print
          print('\x1B[35m┌─── WEBVIEW PAGE STARTED ──────────────────────\x1B[0m');
          // ignore: avoid_print
          print('\x1B[35m│ url: $url\x1B[0m');
          // ignore: avoid_print
          print('\x1B[35m└───────────────────────────────────────────────\x1B[0m');
          if (!mounted) return;
          setState(() => _isLoading = true);
          _checkAndClose(url);
        },
        onPageFinished: (url) {
          // ignore: avoid_print
          print('\x1B[35m┌─── WEBVIEW PAGE FINISHED ─────────────────────\x1B[0m');
          // ignore: avoid_print
          print('\x1B[35m│ url: $url\x1B[0m');
          // ignore: avoid_print
          print('\x1B[35m└───────────────────────────────────────────────\x1B[0m');
          if (!mounted) return;
          setState(() => _isLoading = false);
          _checkAndClose(url);
        },
        onNavigationRequest: (request) {
          // ignore: avoid_print
          print('\x1B[33m┌─── WEBVIEW NAVIGATION REQUEST ────────────────\x1B[0m');
          // ignore: avoid_print
          print('\x1B[33m│ url: ${request.url}\x1B[0m');
          // ignore: avoid_print
          print('\x1B[33m└───────────────────────────────────────────────\x1B[0m');
          _checkAndClose(request.url);
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          // ignore: avoid_print
          print('\x1B[31m┌─── WEBVIEW ERROR ─────────────────────────────\x1B[0m');
          // ignore: avoid_print
          print('\x1B[31m│ error: ${error.description} (${error.errorCode})\x1B[0m');
          // ignore: avoid_print
          print('\x1B[31m│ url  : ${error.url}\x1B[0m');
          // ignore: avoid_print
          print('\x1B[31m└───────────────────────────────────────────────\x1B[0m');
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkAndClose(String url) {
    if (_closed) return;
    final isActivateOrder = url.contains('activate-order') || url.contains('activate_order');
    // ignore: avoid_print
    print('\x1B[36m┌─── WEBVIEW URL CHECK ──────────────────────────\x1B[0m');
    // ignore: avoid_print
    print('\x1B[36m│ url            : $url\x1B[0m');
    // ignore: avoid_print
    print('\x1B[36m│ isActivateOrder: $isActivateOrder\x1B[0m');
    // ignore: avoid_print
    print('\x1B[36m└───────────────────────────────────────────────\x1B[0m');
    if (isActivateOrder) {
      _closed = true;
      // ignore: avoid_print
      print('\x1B[32m┌─── PAYMENT SUCCESS DETECTED ──────────────────\x1B[0m');
      // ignore: avoid_print
      print('\x1B[32m│ activate-order URL detected → closing WebView\x1B[0m');
      // ignore: avoid_print
      print('\x1B[32m└───────────────────────────────────────────────\x1B[0m');
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
