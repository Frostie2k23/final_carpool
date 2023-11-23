import 'dart:async';
import 'dart:typed_data';

import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/trip/trips_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class MonitorStudentScreen extends StatefulWidget {
  const MonitorStudentScreen({
    super.key,
    required this.studentId,
    required this.tripId,
    // required this.driverId
  });

  final String tripId;
  final String studentId;
  // final String driverId;

  @override
  State<MonitorStudentScreen> createState() => _MonitorStudentScreenState();
}

class _MonitorStudentScreenState extends State<MonitorStudentScreen> {
  GoogleMapController? _controller; // Controller for the GoogleMap widget

  // Attach an event listener to the node
  StreamSubscription? driverLocationsubscription;

  TripStatus? currentTripStatus;

  LatLng? driverLatLng;

  Set<Marker> markers = {};

  //! Driver icon

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    getBytesFromAsset(path: "lib/assets/images/car_pin.png", width: 100)
        .then((value) {
      setState(() {
        markerIcon = BitmapDescriptor.fromBytes(value);
      });
    });
  }

  Future<Uint8List> getBytesFromAsset(
      {required String path, required int width}) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
  //!

  //Trip details

  void listenToDriverLocations(String driverId) {
    driverLocationsubscription = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(driverId)
        .onValue
        .listen((event) {
      // Get the data from the event snapshot
      final data = event.snapshot.value;

      if (data != null) {
        final dataMap = (data as Map<dynamic, dynamic>);
        // print(dataMap);
        // final driverData =
        //     Map<String, dynamic>.from(dataMap.values.elementAt(0) as Map);
        // print(' $driverData');

        // print(driverData["latitude"]);
        driverLatLng = LatLng(dataMap["latitude"], dataMap["longitude"]);

        if (mounted) {
          //check the trip state

          if (driverLatLng != null) {
            _animateCamera(driverLatLng!);

            setState(() {
              Marker resultMarker = Marker(
                markerId: const MarkerId('driver location'),
                position: LatLng(
                    driverLatLng?.latitude ?? 0, driverLatLng?.longitude ?? 0),
                icon: markerIcon,
              );
              markers.add(resultMarker);
            });
          }
        } else {
          print("not mounted");
        }
      }

      // double lat = data?.latitude;

      // Do something with the data
    });
  }

  _animateCamera(LatLng latLng) async {
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    FirebaseFirestore.instance
        .collection("trips")
        .doc(widget.tripId)
        .snapshots()
        .map((event) => Trip.fromJson(event.data() as Map<String, dynamic>))
        .listen((event) {
      setState(() {
        currentTripStatus = event.status;
      });
      if (driverLocationsubscription == null) {
        listenToDriverLocations(event.driverId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitor Student"),
        backgroundColor: Colors.redAccent,
      ),
      body: Stack(
        children: [
          GoogleMap(
            // polylines: Set<Polyline>.of(polylines.values),
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _controller = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: driverLatLng ?? const LatLng(0, 0),
              zoom: 14.0,
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Current Trip Status",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      tripStatusToString(currentTripStatus!),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
