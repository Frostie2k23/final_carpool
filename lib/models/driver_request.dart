enum RequestStatus {
  pending,
  accepted,
  completed,
  cancelled,
}

class DriverRequest {
  String requestId;
  String passengerID;
  String passengerName;
  double pickupLatitude;
  double pickupLongitude;
  double dropoffLatitude;
  double dropoffLongitude;
  num distance;
  RequestStatus status;
  int tripType;

  String tripDistance;
  String tripDuration;

  DriverRequest(
      {required this.requestId,
      required this.passengerName,
      required this.pickupLatitude,
      required this.pickupLongitude,
      required this.dropoffLatitude,
      required this.dropoffLongitude,
      required this.distance,
      required this.status,
      required this.tripType,
      required this.tripDistance,
      required this.tripDuration,
      required this.passengerID});

  factory DriverRequest.fromJson(Map<String, dynamic> json) {
    // print(json);
    return DriverRequest(
      requestId: json['requestId'],
      passengerName: json['passengerName'],
      pickupLatitude: json['pickupLatitude'],
      pickupLongitude: json['pickupLongitude'],
      dropoffLatitude: json['dropoffLatitude'],
      dropoffLongitude: json['dropoffLongitude'],
      distance: json['distance'],
      status: _parseStatus(json['status']),
      tripType: json['tripType'],
      tripDistance: json['tripDistance'],
      tripDuration: json['tripDuration'],
      passengerID: json['passengerID'],
    );
  }

  static RequestStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }
}
