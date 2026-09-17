class AppDefaults {
  // Driver Defaults
  static const String driverName = 'Ramesh Kumar';
  static const String upiId = 'ramesh.auto@okhdfcbank';
  static const String vehicleNumber = 'KA-01-AB-4022';
  static const String currency = '₹';

  // Fare Defaults (Standard prototype config)
  static const double baseFare = 30.00;        // Base minimum charge
  static const double perKmRate = 15.00;       // Rate per kilometer
  static const double waitingRatePerMin = 1.50;// Waiting charge per minute

  // GPS & Vehicle Dynamics Defaults
  static const double minMovingSpeedKmh = 4.0; // Speeds below this accumulate waiting time
  static const double maxReliableSpeedKmh = 90.0;// Ignore GPS jumps exceeding rickshaw capability
  static const double maxGpsAccuracyMeters = 30.0;// Ignore poor fixes with error > 30m

  // Demo Simulation Defaults
  static const double demoDrivingSpeedKmh = 32.0; // Realistic city auto speed
}
