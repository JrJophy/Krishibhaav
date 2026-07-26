import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A map to store mock OTP data in debug mode: mobile -> { 'code': String, 'expiry': DateTime }
  final Map<String, Map<String, dynamic>> _mockOtps = {};

  Future<String> registerUser({
    required String name,
    required String mobile,
    required String password,
    required String role,
    required String location,
  }) async {
    if (kDebugMode) {
      // Generate a random 6-digit code
      final random = Random();
      final code = List.generate(6, (_) => random.nextInt(10).toString()).join();

      // Store in memory with a 5-minute expiry
      _mockOtps[mobile] = {
        'code': code,
        'expiry': DateTime.now().add(const Duration(minutes: 5)),
      };

      // Print to debug console
      debugPrint('====================================');
      debugPrint('[DEBUG] Mock OTP generated for $mobile: $code');
      debugPrint('====================================');

      return code;
    }

    Completer<String> completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$mobile',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );

    return completer.future;
  }

  Future<bool> verifyOTPAndCreateUser({
    required String otpEntered,
    required String otpGenerated, // This is verificationId
    required Map<String, dynamic> userData,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        final mobile = userData['mobile'] as String;
        final mockData = _mockOtps[mobile];
        if (mockData == null) return false;

        final code = mockData['code'] as String;
        final expiry = mockData['expiry'] as DateTime;

        if (DateTime.now().isAfter(expiry)) {
          _mockOtps.remove(mobile);
          return false;
        }

        if (code != otpEntered) {
          return false;
        }

        // Mock verification passed: proceed with email/password creation directly without linking phone credential
        final email = '${userData['mobile']}@krishibhaav.app';
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user!.uid;
        userData['uid'] = uid;

        if (userData['role'] == 'agent') {
          final agentCode = uid.substring(0, 6).toUpperCase();
          userData['agentCode'] = agentCode;

          await _firestore.collection('agent_settings').doc(uid).set({
            'openMarketPrice': 0,
            'companyPrice': 0,
            'globalAgentPrice': 0,
          });
        }

        await _firestore.collection('users').doc(uid).set(userData);
        return true;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: otpGenerated,
        smsCode: otpEntered,
      );

      final email = '${userData['mobile']}@krishibhaav.app';
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;

      // Verify the phone number by linking the credential
      await userCredential.user!.linkWithCredential(credential);

      userData['uid'] = uid;
      
      if (userData['role'] == 'agent') {
        final agentCode = uid.substring(0, 6).toUpperCase();
        userData['agentCode'] = agentCode;
        
        await _firestore.collection('agent_settings').doc(uid).set({
          'openMarketPrice': 0,
          'companyPrice': 0,
          'globalAgentPrice': 0,
        });
      }

      await _firestore.collection('users').doc(uid).set(userData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> signIn({
    required String mobile,
    required String password,
  }) async {
    final email = '$mobile@krishibhaav.app';
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
    if (userDoc.exists) {
      return userDoc.get('role') as String;
    }
    throw Exception('User document not found');
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
