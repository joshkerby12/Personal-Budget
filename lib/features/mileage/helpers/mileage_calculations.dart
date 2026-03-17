/// Total miles driven (doubles one-way if round trip).
double totalMiles(double oneWayMiles, bool isRoundTrip) {
  return isRoundTrip ? oneWayMiles * 2 : oneWayMiles;
}

/// Miles eligible for IRS deduction.
double deductibleMiles(double total, double bizPct) {
  return total * bizPct;
}

/// Dollar value of deduction.
double deductibleValue(double dedMiles, double irsRatePerMile) {
  return dedMiles * irsRatePerMile;
}

// TODO(TASK-007): replace with appSettingsProvider.
const double fallbackIrsRatePerMile = 0.670;
