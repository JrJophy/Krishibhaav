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



  Future<void> updateFarmerProfile(String farmerId, String name, String location) async {
    await _firestore.collection('users').doc(farmerId).update({
      'name': name,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFarmerVisibility(String farmerId, bool canSeeBoardRate, bool canSeeOpenMarket) async {
    // Owns: canSeeBoardRate, canSeeOpenMarket, updatedAt
    await _firestore.collection('farmer_prices').doc(farmerId).set({
      'canSeeBoardRate': canSeeBoardRate,
      'canSeeOpenMarket': canSeeOpenMarket,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setCustomPrice(String farmerId, double price) async {
    // Owns: hasCustomPrice, customPrice, updatedAt
    await _firestore.collection('farmer_prices').doc(farmerId).set({
      'hasCustomPrice': true,
      'customPrice': price,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearCustomPrice(String farmerId) async {
    // Owns: hasCustomPrice, customPrice, updatedAt
    await _firestore.collection('farmer_prices').doc(farmerId).set({
      'hasCustomPrice': false,
      'customPrice': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFarmer(String farmerId) async {
    await _firestore.collection('farmer_prices').doc(farmerId).delete();
    await _firestore.collection('users').doc(farmerId).delete();
  }
}
