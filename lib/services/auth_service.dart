import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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
    required String otpGenerated, // This is now verificationId
    required Map<String, dynamic> userData,
    required String password,
  }) async {
    try {
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
