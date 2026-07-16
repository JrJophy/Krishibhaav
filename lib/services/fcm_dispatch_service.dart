import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FcmDispatchService {
  Future<void> notifyOpenMarketPriceUpdate(String agentId, double rss4, double rss5) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('notifyOpenMarketPriceUpdate');
      await callable.call({
        'agentId': agentId,
        'rss4': rss4,
        'rss5': rss5,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] notifyOpenMarketPriceUpdate error: $e');
    }
  }

  Future<void> notifyBoardRateUpdate(String agentId, double rss4, double rss5) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('notifyBoardRateUpdate');
      await callable.call({
        'agentId': agentId,
        'rss4': rss4,
        'rss5': rss5,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] notifyBoardRateUpdate error: $e');
    }
  }

  Future<void> notifyAgentPriceUpdate(String agentId, double price) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('notifyAgentPriceUpdate');
      await callable.call({
        'agentId': agentId,
        'price': price,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] notifyAgentPriceUpdate error: $e');
    }
  }

  Future<void> notifyCustomPriceSet(String farmerId, double price) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('notifyCustomPriceSet');
      await callable.call({
        'farmerId': farmerId,
        'price': price,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] notifyCustomPriceSet error: $e');
    }
  }

  Future<void> notifyCustomPriceReverted(String farmerId, double globalPrice) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('notifyCustomPriceReverted');
      await callable.call({
        'farmerId': farmerId,
        'globalPrice': globalPrice,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] notifyCustomPriceReverted error: $e');
    }
  }
  Future<void> notifyLinkRequest(String agentId, String farmerName) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('notifyLinkRequest');
      await callable.call({
        'agentId': agentId,
        'farmerName': farmerName,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] notifyLinkRequest error: $e');
    }
  }

  Future<void> acceptLinkRequest(String requestId, String farmerId, String agentName) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('acceptLinkRequest');
      await callable.call({
        'requestId': requestId,
        'farmerId': farmerId,
        'agentName': agentName,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] acceptLinkRequest error: $e');
      rethrow;
    }
  }

  Future<void> rejectLinkRequest(String requestId, String farmerId, String agentName) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('rejectLinkRequest');
      await callable.call({
        'requestId': requestId,
        'farmerId': farmerId,
        'agentName': agentName,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmDispatchService] rejectLinkRequest error: $e');
      rethrow;
    }
  }
}
