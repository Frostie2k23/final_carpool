import 'package:cloud_firestore/cloud_firestore.dart';

enum TripStatus {
  initial,
  driverArriving,
  driverArrived,
  inProgress,
  completed
}

// This function is used to convert enum values to strings
String tripStatusToString(TripStatus status) {
  return status.toString().split('.').last;
}

// This function is used to convert strings to enum values
TripStatus tripStatusFromString(String status) {
  return TripStatus.values
      .firstWhere((e) => e.toString().split('.').last == status);
}

class Trip {
  final String id;
  final String driverId;
  final String passengerId;
  final TripStatus status;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String tripDistance;
  final String tripDuration;

  final Timestamp date;

  Trip(
      {required this.id,
      required this.driverId,
      required this.passengerId,
      required this.status,
      required this.pickupLatitude,
      required this.pickupLongitude,
      required this.dropoffLatitude,
      required this.dropoffLongitude,
      required this.tripDistance,
      required this.tripDuration,
      required this.date});

  // Convert a Trip instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'passengerId': passengerId,
      'status': tripStatusToString(status),
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropoffLatitude': dropoffLatitude,
      'dropoffLongitude': dropoffLongitude,
      'tripDistance': tripDistance,
      'tripDuration': tripDuration,
      'date': date
    };
  }

  // Create a Trip instance from a JSON map
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      driverId: json['driverId'],
      passengerId: json['passengerId'],
      status: tripStatusFromString(json['status']),
      pickupLatitude: json['pickupLatitude'],
      pickupLongitude: json['pickupLongitude'],
      dropoffLatitude: json['dropoffLatitude'],
      dropoffLongitude: json['dropoffLongitude'],
      tripDistance: json['tripDistance'],
      tripDuration: json['tripDuration'],
      date: json['date'],
    );
  }
}
