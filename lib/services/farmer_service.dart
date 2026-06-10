import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/agent_settings_model.dart';
import '../models/user_model.dart';

class EffectivePriceResult {
  final double price;
  final bool isCustom;

  EffectivePriceResult(this.price, this.isCustom);
}

class FarmerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<EffectivePriceResult> streamEffectivePrice(String farmerId, String agentId) {
    final Stream<DocumentSnapshot> farmerStream = _firestore.collection('farmer_prices').doc(farmerId).snapshots();
    final Stream<DocumentSnapshot> agentStream = _firestore.collection('agent_settings').doc(agentId).snapshots();

    return CombineLatestStream.combine2(
      farmerStream,
      agentStream,
      (DocumentSnapshot farmerDoc, DocumentSnapshot agentDoc) {
        double effectivePrice = 0.0;
        bool isCustom = false;

        if (agentDoc.exists) {
          final agentData = agentDoc.data() as Map<String, dynamic>?;
          final globalAgentPrice = agentData?['globalAgentPrice'] ?? 0.0;

          if (farmerDoc.exists) {
            final farmerData = farmerDoc.data() as Map<String, dynamic>?;
            final hasCustomPrice = farmerData?['hasCustomPrice'] == true;
            final customPrice = farmerData?['customPrice'];

            if (hasCustomPrice && customPrice != null) {
              effectivePrice = (customPrice as num).toDouble();
              isCustom = true;
            } else {
              effectivePrice = (globalAgentPrice as num).toDouble();
              isCustom = false;
            }
          } else {
            effectivePrice = (globalAgentPrice as num).toDouble();
            isCustom = false;
          }
        } else {
          effectivePrice = 0.0;
          isCustom = false;
        }

        return EffectivePriceResult(effectivePrice, isCustom);
      },
    );
  }

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

  Future<UserModel?> getFarmerUser(String farmerId) async {
    final doc = await _firestore.collection('users').doc(farmerId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
