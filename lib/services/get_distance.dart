import 'package:car_pool/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dartz/dartz.dart';

Future<Tuple2> getDistance(LatLng source, LatLng destinationLat) async {
  String origin =
      '${source.latitude},${source.longitude}'; // replace with your origin
  String destination =
      '${destinationLat.latitude},${destinationLat.longitude}'; // replace with your destination

  String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origin&destinations=$destination&key=$googleMapApiKey';

  http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    String data = response.body;
    var decodedData = jsonDecode(data);

    String distance = decodedData['rows'][0]['elements'][0]['distance']['text'];
    String duration = decodedData['rows'][0]['elements'][0]['duration']['text'];

    // print('Distance: $distance');
    // print('Duration: $duration');

    return tuple2(distance, duration);
  } else {
    print('Failed to load distance');
    return tuple2(-1, -1);
  }
}
