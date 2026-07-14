import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';

class EffectivePriceResult {
  final double price;
  final bool isCustom;
  final bool canSeeBoardRate;
  final bool canSeeOpenMarket;

  EffectivePriceResult(this.price, this.isCustom, this.canSeeBoardRate, this.canSeeOpenMarket);
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
        bool canSeeBoardRate = false;
        bool canSeeOpenMarket = false;

        // 1. Always evaluate farmer visibility flags if farmer_prices doc exists
        if (farmerDoc.exists) {
          final farmerData = farmerDoc.data() as Map<String, dynamic>?;
          canSeeBoardRate = farmerData?['canSeeBoardRate'] == true;
          canSeeOpenMarket = farmerData?['canSeeOpenMarket'] == true;
        }

        // 2. Evaluate effective pricing depending on both docs
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

        return EffectivePriceResult(effectivePrice, isCustom, canSeeBoardRate, canSeeOpenMarket);
      },
    );
  }


  Future<UserModel?> getFarmerUser(String farmerId) async {
    final doc = await _firestore.collection('users').doc(farmerId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
