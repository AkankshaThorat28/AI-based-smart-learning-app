import 'dart:async';
import 'package:flutter/material.dart';

class AppAlerts {
  static void showSuccess(BuildContext context, String message) {
    _showTopBanner(context, message, Colors.green.shade600, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _showTopBanner(context, message, Colors.red.shade600, Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _showTopBanner(context, message, Colors.blue.shade600, Icons.info_outline);
  }

  static void _showTopBanner(BuildContext context, String message, Color color, IconData icon) {
    final overlayState = Overlay.of(context, rootOverlay: true);
    late OverlayEntry overlayEntry;
    
    // We use a StatefulBuilder inside the overlay to handle the slide animation
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _TopBannerWidget(
          message: message,
          color: color,
          icon: icon,
          onDismiss: () => overlayEntry.remove(),
        );
      },
    );

    overlayState.insert(overlayEntry);
  }
}

class _TopBannerWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _TopBannerWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<_TopBannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Auto dismiss
    _dismissTimer = Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Positioned(
      top: topPadding + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    _dismissTimer?.cancel();
                    await _controller.reverse();
                    widget.onDismiss();
                  },
                  child: const Icon(Icons.close, color: Colors.white70, size: 20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
