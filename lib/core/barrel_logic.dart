class BarrelDecision {
  final String? newStatus;
  final int availableDelta;
  const BarrelDecision(this.newStatus, this.availableDelta);
}

BarrelDecision decideApprove(String currentStatus, int quantity, int available) {
  if (currentStatus != 'requested') {
    return const BarrelDecision(null, 0);
  }
  if (available < quantity) {
    throw ArgumentError('overbooking');
  }
  return BarrelDecision('approved', -quantity);
}

BarrelDecision decideDispatch(String currentStatus) {
  if (currentStatus == 'approved') {
    return const BarrelDecision('dispatched', 0);
  }
  return const BarrelDecision(null, 0);
}

BarrelDecision decideReturn(String currentStatus, int quantity) {
  if (currentStatus == 'dispatched') {
    return BarrelDecision('returned', quantity);
  }
  return const BarrelDecision(null, 0);
}

BarrelDecision decideReturnEmpty(String currentStatus, int quantity) {
  if (currentStatus == 'dispatched') {
    return BarrelDecision('returned_empty', quantity);
  }
  return const BarrelDecision(null, 0);
}

BarrelDecision decideReturnFilled(String currentStatus) {
  if (currentStatus == 'dispatched') {
    return const BarrelDecision('returned_filled', 0);
  }
  return const BarrelDecision(null, 0);
}

BarrelDecision decideCancel(String currentStatus, int quantity) {
  if (currentStatus == 'requested') {
    return const BarrelDecision('cancelled', 0);
  }
  if (currentStatus == 'approved') {
    return BarrelDecision('cancelled', quantity);
  }
  return const BarrelDecision(null, 0);
}

int upsertAvailableDelta(int oldTotal, int newTotal) {
  return newTotal - oldTotal;
}

int validatedUpsertDelta(int oldTotal, int newTotal, int currentAvailable) {
  final delta = newTotal - oldTotal;
  if (currentAvailable + delta < 0) {
    throw ArgumentError('Cannot reduce total below outstanding barrels');
  }
  return delta;
}
