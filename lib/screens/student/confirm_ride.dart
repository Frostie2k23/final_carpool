import 'dart:async';

import 'package:car_pool/constants.dart';
import 'package:car_pool/models/booking_request_model.dart';
import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/student/book_ride_screen.dart';
import 'package:car_pool/screens/student/driver_arriving.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:car_pool/services/get_distance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';

class ConfirmRide extends StatefulWidget {
  //const ConfirmRide({super.key, required this.tripType, required this.startLocation});
  const ConfirmRide({
    super.key,
    required this.tripType,
    required this.startLocation,
    required this.studentHome,
  });

  final TripType tripType;
  final LatLng startLocation;
  final LatLng studentHome;

  @override
  State<ConfirmRide> createState() => _ConfirmRideState();
}

class _ConfirmRideState extends State<ConfirmRide> {
  @override
  void initState() {
    super.initState();
    getTripData();
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

  bool _bookingRide = false;
  GoogleMapController? _controller;
  Set<Marker> markers = {};
  dartz.Tuple2? tripDistanceAndDuration;

  var uuid = const Uuid();

  void getTripData() async {
    late LatLng startLocation;
    late LatLng destinationLocation;
    if (widget.tripType == TripType.homeToUniversity) {
//
      startLocation = widget.startLocation;
      destinationLocation = uniAddress;
    } else {
      //
      startLocation = uniAddress;

      destinationLocation = widget.studentHome;
    }
    /*LatLng startLocation = widget.tripType == TripType.homeToUniversity
        ? widget.startLocation
        : uniAddress;*/

    /*LatLng destinationLocation = widget.tripType != TripType.homeToUniversity
        ? widget.startLocation
        : uniAddress;*/

    final result = await getDistance(startLocation, destinationLocation);

    setState(() {
      tripDistanceAndDuration = result;
    });
  }

  //! request stream
  StreamSubscription? subscription;

  void showSuccessAlert(String message) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: message,
        showConfirmBtn: false,
        type: QuickAlertType.success,
      );
    }
  }

  void showErrorAlert(String errorMessage) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: errorMessage,
        showConfirmBtn: true,
        type: QuickAlertType.error,
      );
    }
  }

  _animateCamera(LatLng latLng) async {
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  Future<void> confirmRide(LatLng home) async {
    setState(() {
      _bookingRide = true;
    });

    LatLng startLocation =
        widget.tripType == TripType.homeToUniversity ? home : uniAddress;

    LatLng destinationLocation =
        widget.tripType != TripType.homeToUniversity ? home : uniAddress;

    final result = await getDistance(startLocation, destinationLocation);

    // Create request
    BookingRequest request = BookingRequest(
      bookingTime: Timestamp.fromDate(DateTime.now()),
      driverId: "",
      dropoffLocation: destinationLocation,
      pickupLocation: startLocation,
      userId: AuthService().currentUser!.uid,
      tripType: widget.tripType,
      tripDistance: result.value1,
      tripDuration: result.value2,
    );

    // Add request to Firestore and get the document reference
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection("requests")
        .add(request.toJson());

    // Start listening to the document
    subscription = docRef.snapshots().listen((snapshot) {
      // print(snapshot.data());
      BookingRequest updatedRequest =
          BookingRequest.fromJson(snapshot.data()! as Map<String, dynamic>);

      // Check if the request was accepted
      if (updatedRequest.status == BookingStatus.accepted) {
        setState(() {
          _bookingRide = false;
        });

        // Notify the user
        // ...
        showSuccessAlert("Driver accepted your ride");

        //Craete trip model

        final tripID = uuid.v1();

        Trip tripModel = Trip(
          id: tripID,
          driverId: updatedRequest.driverId,
          passengerId: AuthService().currentUser!.uid,
          status: TripStatus.driverArriving,
          pickupLatitude: startLocation.latitude,
          pickupLongitude: startLocation.longitude,
          dropoffLatitude: destinationLocation.latitude,
          dropoffLongitude: destinationLocation.longitude,
          tripDistance: result.value1,
          tripDuration: result.value2,
          date: Timestamp.now(),
        );

        FirebaseFirestore.instance
            .collection("users")
            .doc(AuthService().currentUser!.uid)
            .update({'onATrip': true, 'currentTripId': tripID});

        FirebaseFirestore.instance
            .collection("users")
            .doc(updatedRequest.driverId)
            .update({'onATrip': true, 'currentTripId': tripID});

        FirebaseFirestore.instance
            .collection("trips")
            .doc(tripID)
            .set(tripModel.toJson());

        context.read<TripsBloc>().add(OngoingTrip(tripModel));

        // Future.delayed(const Duration(seconds: 1)).then((value) {
        //   // Navigate to the DriverArrivingScreen

        // });
        context.read<UserDetailsCubit>().state.whenOrNull(
          loaded: (model) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DriverArrivingScreen(
                  request: updatedRequest,
                  tripModel: tripModel,
                  studentModel: model,
                ),
              ),
            );
          },
        );

        // Cancel the subscription
        subscription?.cancel();
      }
    });

    // Stop listening after 30 seconds
    Future.delayed(const Duration(seconds: 15), () async {
      await subscription?.cancel();

      // Check if still booking
      if (_bookingRide) {
        showErrorAlert("Sorry no available drivers at this moment");
        setState(() {
          _bookingRide = false;
        });

        // Notify the user
        // ...
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: BlocConsumer<UserDetailsCubit, UserDetailsState>(
      listener: (context, state) {
        state.whenOrNull(
          loaded: (model) {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
            loaded: (model) => Stack(
                  children: [
                    GoogleMap(
                      markers: markers,
                      initialCameraPosition: CameraPosition(
                        target: widget.tripType == TripType.homeToUniversity
                            ? LatLng(model.latitude!, model.longitude!)
                            : LatLng(
                                uniAddress.latitude,
                                uniAddress.longitude,
                              ),
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        if (widget.tripType == TripType.homeToUniversity) {
                          if (model.latitude != null &&
                              model.longitude != null) {
                            Marker resultMarker = Marker(
                              markerId: const MarkerId('home location'),
                              position: LatLng(
                                  model.latitude!,
                                  model
                                      .longitude!), // Replace with your desired LatLng
                            );
                            markers.add(resultMarker);
                            setState(() {
                              _controller = controller;
                            });
                            _animateCamera(
                                LatLng(model.latitude!, model.longitude!));
                          }
                        } else {
                          //! for the uni
                          Marker resultMarker = Marker(
                            markerId: const MarkerId('uni location'),
                            position: LatLng(
                                uniAddress.latitude, uniAddress.longitude),
                          );
                          markers.add(resultMarker);
                          setState(() {
                            _controller = controller;
                          });
                          _animateCamera(LatLng(
                              uniAddress.latitude, uniAddress.longitude));
                        }
                      },
                    ),
                    Positioned(
                      top: size.height * 0.045,
                      left: size.width * 0.025,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: const Icon(
                            Icons.menu,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.25,
                                ),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        size: 16,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                          height: size.height * 0.06,
                                          child: const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 0.75,
                                          )),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 35,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: size.width * 0.05,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.tripType ==
                                                TripType.homeToUniversity
                                            ? "Home"
                                            : "University",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      // const Text(
                                      //   "669/24, Fifth street, LA",
                                      //   style: TextStyle(fontSize: 16),
                                      // ),
                                      SizedBox(
                                        height: size.height * 0.045,
                                      ),
                                      Text(
                                        widget.tripType !=
                                                TripType.homeToUniversity
                                            ? "Home"
                                            : "University",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),

                                      // const Text(
                                      //   "669/24, Fifth street, LA",
                                      //   style: TextStyle(fontSize: 16),
                                      // ),
                                    ],
                                  ),
                                  Expanded(
                                      child: Container(
                                    // color: Colors.green,
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Distance ${tripDistanceAndDuration?.value1 ?? 0}",
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Duration ${tripDistanceAndDuration?.value2 ?? 0}",
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: MaterialButton(
                                  minWidth: size.width - 60,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  color: Colors.redAccent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  onPressed: () {
                                    confirmRide(LatLng(
                                        model.latitude!, model.longitude!));
                                  },
                                  child: _bookingRide
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Confirming ride",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          "Next",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
            orElse: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ));
      },
    ));
  }
}
