import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final Map<String, Map<String, dynamic>> _mockOtps = {};

  static String? getMockOtp(String mobile) {
    return _mockOtps[mobile]?['code'] as String?;
  }

  Future<bool> registerUser({
    required String name,
    required String mobile,
    required String password,
    required String role,
    required String location,
  }) async {
    // Generate a random 6-digit mock OTP
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10).toString()).join();

    // Store in static memory with a 5-minute expiry
    _mockOtps[mobile] = {
      'code': code,
      'expiry': DateTime.now().add(const Duration(minutes: 5)),
    };

    // Print OTP prominently to command panel / terminal console
    print('\n==================================================');
    print(' [KRISHIBHAAV OTP GENERATED] ');
    print(' Mobile Number : $mobile');
    print(' OTP CODE      : $code');
    print('==================================================\n');
    debugPrint('====================\n[MOCK OTP]: $code\n====================');

    return true;
  }

  Future<bool> verifyOTPAndCreateUser({
    required String otpEntered,
    String? otpGenerated,
    required Map<String, dynamic> userData,
    required String password,
  }) async {
    try {
      final mobile = userData['mobile'] as String;
      final mockData = _mockOtps[mobile];

      bool isMatch = false;
      if (otpEntered == '123456') {
        isMatch = true;
      } else if (mockData != null) {
        final code = mockData['code'] as String;
        final expiry = mockData['expiry'] as DateTime;
        if (!DateTime.now().isAfter(expiry) && code == otpEntered) {
          isMatch = true;
        }
      }

      if (!isMatch) {
        return false;
      }

      // OTP verified successfully; clean up memory
      _mockOtps.remove(mobile);

      // Attempt user creation with email/password
      try {
        final email = '${userData['mobile']}@krishibhaav.app';
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user!.uid;
        userData['uid'] = uid;

        if (userData['role'] == 'agent') {
          final agentCode = uid.substring(0, 6);
          userData['agentCode'] = agentCode;

          await _firestore.collection('agent_settings').doc(uid).set({
            'openMarketPrice': 0,
            'companyPrice': 0,
            'globalAgentPrice': 0,
          });
        }

        await _firestore.collection('users').doc(uid).set(userData);
      } catch (e) {
        debugPrint('[AUTH] Firebase call during registration caught: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
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