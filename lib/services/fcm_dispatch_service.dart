import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmDispatchService {
  AuthClient? _authClient;

  Future<AuthClient> _getClient() async {
    if (_authClient != null) {
      return _authClient!;
    }
    // Note: Client-side credential handling is an acknowledged academic-scope compromise, 
    // to be replaced with server-side dispatch in V2.
    final jsonString = await rootBundle.loadString('assets/service_account.json');
    final credentials = ServiceAccountCredentials.fromJson(jsonString);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    _authClient = await clientViaServiceAccount(credentials, scopes);
    return _authClient!;
  }

  Future<void> sendNotification({required String token, required String title, required String body}) async {
    if (token.isEmpty) return;

    try {
      final client = await _getClient();
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/krishibhaav/messages:send');
      final payload = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          }
        }
      };

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        debugPrint('[FcmDispatchService] Failed to send to $token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('[FcmDispatchService] Dispatch error for $token: $e');
    }
  }

  Future<List<String>> _getAllFarmerTokens(String agentId) async {
    final firestore = FirebaseFirestore.instance;
    final usersSnap = await firestore.collection('users')
        .where('agentId', isEqualTo: agentId)
        .where('role', isEqualTo: 'farmer')
        .get();
        
    List<String> tokens = [];
    for (final doc in usersSnap.docs) {
      final token = doc.data()['fcmToken'] as String?;
      if (token != null && token.isNotEmpty) {
        tokens.add(token);
      }
    }
    return tokens;
  }

  Future<void> notifyOpenMarketPriceUpdate(String agentId, double price) async {
    try {
      final tokens = await _getAllFarmerTokens(agentId);
      for (final token in tokens) {
        await sendNotification(
          token: token,
          title: 'Open Market Price Updated',
          body: 'Price: ₹${price.toStringAsFixed(2)}/kg',
        );
      }
    } catch (e) {
      debugPrint('[FcmDispatchService] Open market update query error: $e');
    }
  }

  Future<void> notifyCompanyPriceUpdate(String agentId, double price) async {
    try {
      final tokens = await _getAllFarmerTokens(agentId);
      for (final token in tokens) {
        await sendNotification(
          token: token,
          title: 'Company Price Updated',
          body: 'Price: ₹${price.toStringAsFixed(2)}/kg',
        );
      }
    } catch (e) {
      debugPrint('[FcmDispatchService] Company update query error: $e');
    }
  }

  Future<void> notifyAgentPriceUpdate(String agentId, double price) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final usersSnap = await firestore.collection('users')
          .where('agentId', isEqualTo: agentId)
          .where('role', isEqualTo: 'farmer')
          .get();

      List<String> targetTokens = [];
      for (final doc in usersSnap.docs) {
        final token = doc.data()['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          final priceDoc = await firestore.collection('farmer_prices').doc(doc.id).get();
          bool hasCustomPrice = false;
          if (priceDoc.exists) {
            hasCustomPrice = priceDoc.data()?['hasCustomPrice'] ?? false;
          }
          if (!hasCustomPrice) {
            targetTokens.add(token);
          }
        }
      }

      for (final token in targetTokens) {
        await sendNotification(
          token: token,
          title: 'Agent Price Updated',
          body: "Price: ₹${price.toStringAsFixed(2)}/kg",
        );
      }
    } catch (e) {
      debugPrint('[FcmDispatchService] Agent price update query error: $e');
    }
  }

  Future<void> notifyCustomPriceSet(String farmerId, double price) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(farmerId).get();
      final token = doc.data()?['fcmToken'] as String?;
      if (token != null && token.isNotEmpty) {
        await sendNotification(
          token: token,
          title: 'Price Updated',
          body: 'Price: ₹${price.toStringAsFixed(2)}/kg',
        );
      }
    } catch (e) {
      debugPrint('[FcmDispatchService] Custom price set query error: $e');
    }
  }

  Future<void> notifyCustomPriceReverted(String farmerId, double globalPrice) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(farmerId).get();
      final token = doc.data()?['fcmToken'] as String?;
      if (token != null && token.isNotEmpty) {
        await sendNotification(
          token: token,
          title: 'Price Updated',
          body: 'Price: ₹${globalPrice.toStringAsFixed(2)}/kg',
        );
      }
    } catch (e) {
      debugPrint('[FcmDispatchService] Custom price revert query error: $e');
    }
  }
}
