import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:atlas/core/api/api_client.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildImage();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _buildImage() {
    String? resolvedUrl = url;
    if (resolvedUrl != null && resolvedUrl.isNotEmpty && resolvedUrl.startsWith('/')) {
      resolvedUrl = '${ApiClient.imgUrl}$resolvedUrl';
    }

    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return _placeholder();
    }

    if (resolvedUrl.startsWith('assets')) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor ?? const Color(0xFFF9F9F9),
        padding: const EdgeInsets.all(8),
        child: Image.asset(resolvedUrl, fit: fit, errorBuilder: (_, __, ___) => _errorPlaceholder()),
      );
    }
    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      color: null,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => errorWidget ?? _errorPlaceholder(),
      imageBuilder: backgroundColor != null
          ? (_, imageProvider) => ColoredBox(
                color: backgroundColor!,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image(image: imageProvider, fit: fit),
                ),
              )
          : null,
    );
  }

  Widget _placeholder() {
    final color = backgroundColor ?? const Color(0xFFF0F0F0);
    if (width != null || height != null) {
      return Container(
        width: width,
        height: height,
        color: color,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff22B241)),
          ),
        ),
      );
    }
    return ColoredBox(
      color: color,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff22B241)),
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    final color = backgroundColor ?? const Color(0xFFF0F0F0);
    if (width != null || height != null) {
      return Container(
        width: width,
        height: height,
        color: color,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
        ),
      );
    }
    return ColoredBox(
      color: color,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
      ),
    );
  }
}
