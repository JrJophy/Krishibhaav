import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _vapidKey = 'BJKI9X1cl6FweukIw2dkQsdc0dFA_LNiOZIdK8WT3V2p7o9Mpj6NvXfGIcyPnHUn_RveoFkl0xGDYtajCFl9Txk';

  Future<void> init(BuildContext context, String uid) async {
    try {
      debugPrint('[NotificationService] 1. Requesting permission...');
      // 1. Request Permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        debugPrint('[NotificationService] 2. Permission granted. Fetching token...');
        // 2. Get FCM Token
        String? token;
        if (kIsWeb) {
          token = await _messaging.getToken(vapidKey: _vapidKey);
        } else {
          token = await _messaging.getToken();
        }

        debugPrint('[NotificationService] 3. Token fetched: $token');

        if (token != null) {
          debugPrint('[NotificationService] 4. Saving token to Firestore...');
          await _saveToken(uid, token);
        } else {
          debugPrint('[NotificationService] Token was null, skipping save.');
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title: $body'), duration: const Duration(seconds: 4)),
            );
          }
        });
      } else {
        debugPrint('[NotificationService] Permission denied by user.');
      }
    } catch (e) {
      debugPrint('[NotificationService] Error initializing notifications: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
      });
      debugPrint('[NotificationService] 5. FCM token successfully written to Firestore for $uid');
    } catch (e) {
      debugPrint('[NotificationService] Failed to save FCM token: $e');
    }
  }
}
