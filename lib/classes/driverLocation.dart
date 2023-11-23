import 'package:observable_ish/observable_ish.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverLocation {
  RxValue<LatLng> location = RxValue<LatLng>(const LatLng(0, 0));

  // Singleton instance
  static final DriverLocation _singleton = DriverLocation._internal();

  // Factory constructor
  factory DriverLocation() {
    return _singleton;
  }

  // Named constructor
  DriverLocation._internal();

  void updateLocation(LatLng newLocation) {
    location.value = newLocation;
  }
}
