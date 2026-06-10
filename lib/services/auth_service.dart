import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> registerUser({
    required String name,
    required String mobile,
    required String password,
    required String role,
    required String location,
  }) async {
    final email = '$mobile@krishibhaav.app';
    
    // Creates Firebase Auth account
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = _auth.currentUser!.uid;

    if (role == 'agent') {
      await _firestore.collection('agent_settings').doc(uid).set({
        'openMarketPrice': 0,
        'companyPrice': 0,
        'globalAgentPrice': 0,
      });
    }

    // Generate 4-digit OTP code
    final otp = (1000 + Random().nextInt(9000)).toString();
    return otp;
  }

  Future<bool> verifyOTPAndCreateUser({
    required String uid,
    required String otpEntered,
    required String otpGenerated,
    required Map<String, dynamic> userData,
  }) async {
    if (otpEntered == otpGenerated) {
      await _firestore.collection('users').doc(uid).set(userData);
      
      if (userData['role'] == 'agent') {
        await _firestore.collection('agent_settings').doc(uid).set({
          'openMarketPrice': 0,
          'companyPrice': 0,
          'globalAgentPrice': 0,
        }, SetOptions(merge: true));
      }
      return true;
    }
    return false;
  }

  Future<String> signIn({
    required String mobile,
    required String password,
  }) async {
    final email = '$mobile@krishibhaav.app';
    debugPrint('[SIGN_IN] email=[$email] password=[$password]');
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
