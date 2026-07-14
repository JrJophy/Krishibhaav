import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../core/colors.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _vapidKey = 'BJKI9X1cl6FweukIw2dkQsdc0dFA_LNiOZIdK8WT3V2p7o9Mpj6NvXfGIcyPnHUn_RveoFkl0xGDYtajCFl9Txk';

  static OverlayEntry? _overlayEntry;
  static Timer? _toastTimer;

  static void _showToast(BuildContext context, String title, String body) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _toastTimer?.cancel();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final valueGreen = isDark ? AppColors.darkValueGreen : AppColors.lightValueGreen;
    final surfaceTintB = isDark ? AppColors.darkSurfaceTintB : AppColors.lightSurfaceTintB;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
              border: isDark ? Border.all(color: surfaceTintB.withValues(alpha: 0.3)) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: valueGreen),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Center(child: Icon(Icons.notifications, color: AppColors.primary)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: ink, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(body, style: TextStyle(color: ink.withValues(alpha: 0.7), fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: ink.withValues(alpha: 0.5)),
                      onPressed: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                        _toastTimer?.cancel();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _toastTimer = Timer(const Duration(seconds: 5), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> init(BuildContext context, String uid) async {
    try {

      // 1. Request Permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        

        // 2. Get FCM Token
        String? token;
        if (kIsWeb) {
          token = await _messaging.getToken(vapidKey: _vapidKey);
        } else {
          token = await _messaging.getToken();
        }



        if (token != null) {

          await _saveToken(uid, token);
        } else {

        }

        // 3. Listen for token refreshes
        _messaging.onTokenRefresh.listen((newToken) {
          _saveToken(uid, newToken);
        });

        // 4. Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (!context.mounted) return;
          if (message.notification != null) {
            final title = message.notification!.title ?? 'New Message';
            final body = message.notification!.body ?? '';
            _showToast(context, title, body);
          }
        });
      } else {

      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Error initializing notifications: $e');
      }
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });

    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Failed to save FCM token: $e');
      }
    }
  }
}
