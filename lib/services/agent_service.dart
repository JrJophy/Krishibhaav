import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_settings_model.dart';
import '../models/user_model.dart';

class AgentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AgentSettingsModel> streamAgentSettings(String agentId) {
    return _firestore.collection('agent_settings').doc(agentId).snapshots().map((doc) {
      if (!doc.exists) {
        return AgentSettingsModel(
          agentId: agentId,
          openMarketPrice: 0,
          companyPrice: 0,
          globalAgentPrice: 0,
          lastUpdated: Timestamp.now(),
        );
      }
      return AgentSettingsModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Future<void> updateOpenMarketPrice(String agentId, double rss4, double rss5) async {
    await _firestore.collection('agent_settings').doc(agentId).update({
      'openMarketPrice': rss4,
      'openMarketRss5': rss5,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCompanyPrice(String agentId, double price) async {
    await _firestore.collection('agent_settings').doc(agentId).update({
      'companyPrice': price,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGlobalAgentPrice(String agentId, double price) async {
    await _firestore.collection('agent_settings').doc(agentId).update({
      'globalAgentPrice': price,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<UserModel>> streamFarmerList(String agentId) {
    return _firestore.collection('users').where('agentId', isEqualTo: agentId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<String> addFarmer(String agentId, String name, String mobile, String location) async {
    String namePart = name.replaceAll(' ', '').toUpperCase();
    if (namePart.length < 4) {
      namePart = namePart.padRight(4, 'A');
    } else {
      namePart = namePart.substring(0, 4);
    }
    
    String mobilePart = mobile.length >= 4 ? mobile.substring(mobile.length - 4) : mobile.padLeft(4, '0');
    String tempPassword = '$namePart$mobilePart';
    final email = '$mobile@krishibhaav.app';

    // Using a secondary app to avoid signing out the current agent
    final app = await Firebase.initializeApp(
      name: 'Secondary_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    final secondaryAuth = FirebaseAuth.instanceFor(app: app);
    
    try {
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );
      final uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'mobile': mobile,
        'role': 'farmer',
        'location': location,
        'crop': 'Rubber',
        'agentId': agentId,
        'fcmToken': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('farmer_prices').doc(uid).set({
        'farmerId': uid,
        'agentId': agentId,
        'hasCustomPrice': false,
        'customPrice': null,
        'canSeeBoardRate': false,
        'canSeeOpenMarket': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return tempPassword;
    } finally {
      await app.delete();
    }
  }

  Future<void> updateFarmerProfile(String farmerId, String name, String location) async {
    await _firestore.collection('users').doc(farmerId).update({
      'name': name,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFarmerVisibility(String farmerId, bool canSeeBoardRate, bool canSeeOpenMarket) async {
    await _firestore.collection('farmer_prices').doc(farmerId).update({
      'canSeeBoardRate': canSeeBoardRate,
      'canSeeOpenMarket': canSeeOpenMarket,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setCustomPrice(String farmerId, double price) async {
    await _firestore.collection('farmer_prices').doc(farmerId).update({
      'hasCustomPrice': true,
      'customPrice': price,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearCustomPrice(String farmerId) async {
    await _firestore.collection('farmer_prices').doc(farmerId).update({
      'hasCustomPrice': false,
      'customPrice': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFarmer(String farmerId) async {
    await _firestore.collection('farmer_prices').doc(farmerId).delete();
    await _firestore.collection('users').doc(farmerId).delete();
  }
}
