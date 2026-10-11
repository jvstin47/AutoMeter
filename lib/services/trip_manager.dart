// Re-export for backward compatibility
import '../providers/trip_provider.dart';
export '../providers/trip_provider.dart';

/// Type alias ensuring legacy code referencing TripManager works identically with TripProvider.
typedef TripManager = TripProvider;
