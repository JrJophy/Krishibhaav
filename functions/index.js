const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyOpenMarketPriceUpdate = onCall(async (request) => {
  const { agentId, rss4, rss5 } = request.data;
  if (!agentId || rss4 == null || rss5 == null) {
    throw new HttpsError('invalid-argument', 'Missing agentId, rss4, or rss5');
  }

  const db = admin.firestore();
  const usersSnap = await db.collection('users')
    .where('agentId', '==', agentId)
    .where('role', '==', 'farmer')
    .get();

  const targetTokens = [];
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    if (data.fcmToken) {
      const priceDoc = await db.collection('farmer_prices').doc(doc.id).get();
      if (priceDoc.exists && priceDoc.data().canSeeOpenMarket === true) {
        targetTokens.push(data.fcmToken);
      }
    }
  }

  if (targetTokens.length > 0) {
    const payload = {
      notification: {
        title: 'Open Market Price Updated',
        body: `RSS4 ₹${rss4.toFixed(2)} · RSS5 ₹${rss5.toFixed(2)} /kg`,
      },
      tokens: targetTokens,
    };
    await admin.messaging().sendEachForMulticast(payload);
  }
  return { success: true, count: targetTokens.length };
});

exports.notifyBoardRateUpdate = onCall(async (request) => {
  const { agentId, rss4, rss5 } = request.data;
  if (!agentId || rss4 == null || rss5 == null) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  const usersSnap = await db.collection('users')
    .where('agentId', '==', agentId)
    .where('role', '==', 'farmer')
    .get();

  const targetTokens = [];
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    if (data.fcmToken) {
      const priceDoc = await db.collection('farmer_prices').doc(doc.id).get();
      if (priceDoc.exists && priceDoc.data().canSeeBoardRate === true) {
        targetTokens.push(data.fcmToken);
      }
    }
  }

  if (targetTokens.length > 0) {
    const payload = {
      notification: {
        title: 'Board Rate Updated',
        body: `RSS4 ₹${rss4.toFixed(2)} · RSS5 ₹${rss5.toFixed(2)} /kg`,
      },
      tokens: targetTokens,
    };
    await admin.messaging().sendEachForMulticast(payload);
  }
  return { success: true, count: targetTokens.length };
});

exports.notifyAgentPriceUpdate = onCall(async (request) => {
  const { agentId, price } = request.data;
  if (!agentId || price == null) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  const usersSnap = await db.collection('users')
    .where('agentId', '==', agentId)
    .where('role', '==', 'farmer')
    .get();

  const targetTokens = [];
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    if (data.fcmToken) {
      const priceDoc = await db.collection('farmer_prices').doc(doc.id).get();
      let hasCustomPrice = false;
      if (priceDoc.exists) {
        hasCustomPrice = priceDoc.data().hasCustomPrice === true;
      }
      if (!hasCustomPrice) {
        targetTokens.push(data.fcmToken);
      }
    }
  }

  if (targetTokens.length > 0) {
    const payload = {
      notification: {
        title: 'Agent Price Updated',
        body: `Price: ₹${price.toFixed(2)}/kg`,
      },
      tokens: targetTokens,
    };
    await admin.messaging().sendEachForMulticast(payload);
  }
  return { success: true, count: targetTokens.length };
});

exports.notifyCustomPriceSet = onCall(async (request) => {
  const { farmerId, price } = request.data;
  if (!farmerId || price == null) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  const doc = await db.collection('users').doc(farmerId).get();
  if (doc.exists && doc.data().fcmToken) {
    const payload = {
      notification: {
        title: 'Price Updated',
        body: `Price: ₹${price.toFixed(2)}/kg`,
      },
      token: doc.data().fcmToken,
    };
    await admin.messaging().send(payload);
    return { success: true, count: 1 };
  }
  return { success: true, count: 0 };
});

exports.notifyCustomPriceReverted = onCall(async (request) => {
  const { farmerId, globalPrice } = request.data;
  if (!farmerId || globalPrice == null) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  const doc = await db.collection('users').doc(farmerId).get();
  if (doc.exists && doc.data().fcmToken) {
    const payload = {
      notification: {
        title: 'Price Updated',
        body: `Price: ₹${globalPrice.toFixed(2)}/kg`,
      },
      token: doc.data().fcmToken,
    };
    await admin.messaging().send(payload);
    return { success: true, count: 1 };
  }
  return { success: true, count: 0 };
});

exports.notifyLinkRequest = onCall(async (request) => {
  const { agentId, farmerName } = request.data;
  if (!agentId || !farmerName) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  const doc = await db.collection('users').doc(agentId).get();
  if (doc.exists && doc.data().fcmToken) {
    const payload = {
      notification: {
        title: 'New Link Request',
        body: `${farmerName} wants to link with you.`,
      },
      token: doc.data().fcmToken,
    };
    await admin.messaging().send(payload);
    return { success: true, count: 1 };
  }
  return { success: true, count: 0 };
});

exports.acceptLinkRequest = onCall(async (request) => {
  const { requestId, farmerId, agentName } = request.data;
  const agentId = request.auth?.uid;
  if (!requestId || !farmerId || !agentName || !agentId) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  
  // Validate request exists and belongs to this agent
  const reqDoc = await db.collection('link_requests').doc(requestId).get();
  if (!reqDoc.exists || reqDoc.data().agentId !== agentId || reqDoc.data().farmerId !== farmerId || reqDoc.data().status !== 'pending') {
    throw new HttpsError('permission-denied', 'Invalid or unauthorized link request');
  }

  // Update farmer's user doc
  await db.collection('users').doc(farmerId).update({ agentId: agentId });
  
  // Update link request status
  await db.collection('link_requests').doc(requestId).update({ status: 'accepted' });

  // Send notification
  const farmerDoc = await db.collection('users').doc(farmerId).get();
  if (farmerDoc.exists && farmerDoc.data().fcmToken) {
    const payload = {
      notification: {
        title: 'Request Accepted',
        body: `You are now linked with ${agentName}.`,
      },
      token: farmerDoc.data().fcmToken,
    };
    await admin.messaging().send(payload);
    return { success: true, count: 1 };
  }
  return { success: true, count: 0 };
});

exports.rejectLinkRequest = onCall(async (request) => {
  const { requestId, farmerId, agentName } = request.data;
  const agentId = request.auth?.uid;
  if (!requestId || !farmerId || !agentName || !agentId) {
    throw new HttpsError('invalid-argument', 'Missing parameters');
  }

  const db = admin.firestore();
  
  // Validate request exists and belongs to this agent
  const reqDoc = await db.collection('link_requests').doc(requestId).get();
  if (!reqDoc.exists || reqDoc.data().agentId !== agentId || reqDoc.data().farmerId !== farmerId || reqDoc.data().status !== 'pending') {
    throw new HttpsError('permission-denied', 'Invalid or unauthorized link request');
  }

  // Update link request status
  await db.collection('link_requests').doc(requestId).update({ status: 'rejected' });

  // Send notification
  const farmerDoc = await db.collection('users').doc(farmerId).get();
  if (farmerDoc.exists && farmerDoc.data().fcmToken) {
    const payload = {
      notification: {
        title: 'Request Rejected',
        body: `${agentName} rejected your link request.`,
      },
      token: farmerDoc.data().fcmToken,
    };
    await admin.messaging().send(payload);
    return { success: true, count: 1 };
  }
  return { success: true, count: 0 };
});

exports.expireStaleLinkRequests = onSchedule("every 24 hours", async (event) => {
  const db = admin.firestore();
  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

  const snapshot = await db.collection('link_requests')
    .where('status', '==', 'pending')
    .where('requestedAt', '<', admin.firestore.Timestamp.fromDate(oneDayAgo))
    .get();

  if (snapshot.empty) {
    console.log('No stale link requests found.');
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach(doc => {
    batch.update(doc.ref, { status: 'expired' });
  });

  await batch.commit();
  console.log(`Expired ${snapshot.size} stale link requests.`);
});

