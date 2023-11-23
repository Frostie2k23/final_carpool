import 'package:car_pool/models/trip_model.dart';

abstract class TripsEvent {}

class OngoingTrip extends TripsEvent {
  final Trip trip;

  OngoingTrip(this.trip);
}

class EndTrip extends TripsEvent {}

class ListenToTripDocEvent extends TripsEvent {}

class TripDataReceived extends TripsEvent {
  final Trip trip;

  TripDataReceived(this.trip);
}

class TripStartedEvent extends TripsEvent {}

class DriverArrivingEvent extends TripsEvent {}

class DriverArrivedEvent extends TripsEvent {}

class InProgressEvent extends TripsEvent {}

class TripCompletedEvent extends TripsEvent {}

class DriverArrivedToCustomerEvent extends TripsEvent {}

class TripInProgressCustomerEvent extends TripsEvent {}

class TripCompletedCustomerEvent extends TripsEvent {}

class TripResetValuesCustomerEvent extends TripsEvent {}
