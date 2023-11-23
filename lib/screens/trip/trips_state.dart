import 'package:car_pool/models/trip_model.dart';

enum CurrentTripStatus {
  initial,
  driverArriving,
  driverArrived,
  inProgress,
  completed
}

class TripState {
  final CurrentTripStatus status;
  final Trip? trip;

  TripState({this.status = CurrentTripStatus.initial, this.trip});

  TripState copyWith({
    CurrentTripStatus? status,
    Trip? trip,
  }) {
    return TripState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
    );
  }
}
