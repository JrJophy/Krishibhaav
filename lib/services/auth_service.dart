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
    final email = '$mobile@krishibhaav.app';
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user!;
    final uid = user.uid;

    try {
      final userData = <String, dynamic>{
        'uid': uid,
        'name': name,
        'mobile': mobile,
        'role': role,
        'location': location,
        'crop': 'Rubber',
        'fcmToken': '',
      };

      if (role == 'agent') {
        final agentCode = uid.substring(0, 6).toUpperCase();
        userData['agentCode'] = agentCode;

        await _firestore.collection('agent_codes').doc(agentCode).set({
          'agentId': uid,
        });

        await _firestore.collection('agent_settings').doc(uid).set({
          'openMarketPrice': 0,
          'companyPrice': 0,
          'globalAgentPrice': 0,
        });
      }

      await _firestore.collection('users').doc(uid).set(userData);
      return uid;
    } catch (e) {
      if (role == 'agent') {
        final agentCode = uid.substring(0, 6).toUpperCase();
        try {
          await _firestore.collection('agent_codes').doc(agentCode).delete();
        } catch (_) {}
        try {
          await _firestore.collection('agent_settings').doc(uid).delete();
        } catch (_) {}
      }
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {}
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
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