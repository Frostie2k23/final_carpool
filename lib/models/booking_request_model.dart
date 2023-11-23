import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_pool/screens/student/book_ride_screen.dart';

enum BookingStatus { requested, accepted, inProgress, completed, cancelled }

class BookingRequest {
  String userId;
  String driverId;
  LatLng pickupLocation;
  LatLng dropoffLocation;
  Timestamp bookingTime;
  BookingStatus status;
  TripType tripType;
  String tripDistance;
  String tripDuration;

  BookingRequest({
    required this.userId,
    required this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.bookingTime,
    required this.tripType,
    this.status = BookingStatus.requested,
    required this.tripDistance,
    required this.tripDuration,
  });

  // Convert a BookingRequest into a Map. The keys must correspond to what you expect to receive in the JSON payload
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'driverId': driverId,
        'pickupLocation': {
          'latitude': pickupLocation.latitude,
          'longitude': pickupLocation.longitude,
        },
        'dropoffLocation': {
          'latitude': dropoffLocation.latitude,
          'longitude': dropoffLocation.longitude,
        },
        'bookingTime': bookingTime,
        'status': status.index,
        'tripType': tripType.index,
        'tripDistance': tripDistance,
        'tripDuration': tripDuration
      };

  // A method to revive a BookingRequest from a Map. The keys must correspond to what you expect to receive in the JSON payload
  factory BookingRequest.fromJson(Map<String, dynamic> json) => BookingRequest(
        userId: json['userId'],
        driverId: json['driverId'],
        pickupLocation: LatLng(
          json['pickupLocation']['latitude'],
          json['pickupLocation']['longitude'],
        ),
        dropoffLocation: LatLng(
          json['dropoffLocation']['latitude'],
          json['dropoffLocation']['longitude'],
        ),
        bookingTime: json['bookingTime'],
        status: BookingStatus.values[json['status']],
        tripType: TripType.values[json['tripType']],
        tripDistance: json['tripDuration'],
        tripDuration: json['tripDuration'],
      );
}
