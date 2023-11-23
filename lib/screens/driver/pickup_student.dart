import 'dart:async';
import 'dart:ui' as ui;

import 'package:car_pool/classes/driverLocation.dart';
import 'package:car_pool/classes/student.dart';
import 'package:car_pool/constants.dart';
import 'package:car_pool/models/driver_request.dart';
import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/screens/trip/trips_state.dart';
import 'package:car_pool/services/chatService.dart';
import 'package:car_pool/services/emergency_service.dart';
import 'package:car_pool/services/get_distance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupStudent extends StatefulWidget {
  const PickupStudent({
    super.key,
    required this.request,
    required this.studentModel,
  });

  final DriverRequest request;
  final Student studentModel;

  @override
  State<PickupStudent> createState() => _PickupStudentState();
}

class _PickupStudentState extends State<PickupStudent> {
  GoogleMapController? _controller; // Controller for the GoogleMap widget
  LatLng? driverLocation; // Current location of the driver

  LatLng? pickUpLocation;
  LatLng? dropOffLocation;

  Set<Marker> markers = {};

  final driverLocationObservable = DriverLocation();

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  getDirections(CurrentTripStatus currentTripStatus) async {
    List<LatLng> polylineCoordinates = [];

    print(currentTripStatus);

// result gets little bit late as soon as in video, because package // send http request for getting real road routes

    if (currentTripStatus == CurrentTripStatus.driverArriving) {
      if (driverLocation != null && pickUpLocation != null) {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleMapApiKey, //GoogleMap ApiKey
          PointLatLng(driverLocation!.latitude,
              driverLocation!.longitude), //first added marker
          PointLatLng(pickUpLocation!.latitude,
              pickUpLocation!.longitude), //last added marker
// define travel mode driving for real roads
          travelMode: TravelMode.driving,
// waypoints is markers that between first and last markers        wayPoints: polylineWayPoints
        );
// Sometimes There is no result for example you can put maker to the // ocean, if results not empty adding to polylineCoordinates
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        } else {
          print(result.errorMessage);
        }
      }

      // newSetState(() {});
    } else if (currentTripStatus == CurrentTripStatus.inProgress) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapApiKey, //GoogleMap ApiKey
        PointLatLng(driverLocation!.latitude, driverLocation!.longitude),
        PointLatLng(dropOffLocation!.latitude, dropOffLocation!.longitude),
        //first added marker
        //last added marker
// define travel mode driving for real roads
        travelMode: TravelMode.driving,
// waypoints is markers that between first and last markers        wayPoints: polylineWayPoints
      );

// Sometimes There is no result for example you can put maker to the // ocean, if results not empty adding to polylineCoordinates
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(result.errorMessage);
      }
    }

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(
    List<LatLng> polylineCoordinates,
  ) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 4,
    );

    if (mounted) {
      setState(() {
        polylines[id] = polyline;
      });
    }
  }

  final CollectionReference chat =
      FirebaseFirestore.instance.collection('chat');

  String message = '';
  final _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool sendButtonLoading = false;

  dartz.Tuple2? distanceAndDurationBetweenDriverAndStudent;

  dartz.Tuple2? distanceAndDurationBetweenDriverAndDestination;

  Student? studentDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    addCustomIcon();
    loadCusDetails();

    pickUpLocation =
        LatLng(widget.request.pickupLatitude, widget.request.pickupLongitude);

    dropOffLocation =
        LatLng(widget.request.dropoffLatitude, widget.request.dropoffLongitude);

    if (pickUpLocation != null) {
      Marker stuMarker = Marker(
          markerId: const MarkerId('student location'),
          position: pickUpLocation!
          //  Replace with your desired LatLng
          );
      setState(() {
        markers.add(stuMarker);
      });
    }

    driverLocationObservable.location.values.listen((event) {
      // print(event);
      if (mounted) {
        //check the trip state
        final cTripStatus = context.read<TripsBloc>().state.status;
        getDirections(cTripStatus);

        setState(() {
          Marker resultMarker = Marker(
              markerId: const MarkerId('driver location'),
              position: event, // Replace with your desired LatLng
              icon: markerIcon);
          markers.add(resultMarker);
          driverLocation = event;
          _animateCamera(event);
        });

        if (cTripStatus == CurrentTripStatus.driverArriving) {
          getDistance(event, pickUpLocation!).then((value) {
            setState(() {
              distanceAndDurationBetweenDriverAndStudent = value;
            });
          });
        } else if (cTripStatus == CurrentTripStatus.inProgress) {
          getDistance(event, dropOffLocation!).then((value) {
            setState(() {
              distanceAndDurationBetweenDriverAndDestination = value;
              // print(distanceAndDurationBetweenDriverAndDestination);
            });
          });
        } else if (currentTripStatus == CurrentTripStatus.completed) {
          polylines = {};
        }
      }
    });
  }

  void _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // return Future.error(
        //     'Location permissions are permanently denied, we cannot request permissions.');
      }
      final position = await Geolocator.getCurrentPosition();

      try {
        // await FirebaseFirestore.instance
        //     .collection("users")
        //     .doc(AuthService().currentUser!.uid)
        //     .update({
        //   'latitude': _currentPosition!.latitude,
        //   'longitude': _currentPosition!.longitude
        // });
        // showSuccessAlert();
        driverLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          Marker resultMarker = Marker(
              markerId: const MarkerId('driver location'),
              position: driverLocation!, // Replace with your desired LatLng
              icon: markerIcon);
          markers.add(resultMarker);
        });
        _animateCamera(driverLocation!);
      } catch (e) {
        // showErrorAlert(
        //     "Unexpected error occurred while updating location . Please try again");
      }
    } catch (e) {
      print(e);
    }
  }

  _animateCamera(LatLng latLng) async {
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  void loadCusDetails() async {
    final driverDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.request.passengerID)
        .get();

    if (driverDoc.exists) {
      if (mounted) {
        setState(() {
          studentDetails = Student.fromJson(driverDoc.data()!);
        });
      }
    }
  }

  //! Driver icon

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  void addCustomIcon() {
    getBytesFromAsset(path: "lib/assets/images/car_pin.png", width: 100)
        .then((value) {
      setState(() {
        markerIcon = BitmapDescriptor.fromBytes(value);
      });
    });
    // BitmapDescriptor.fromAssetImage(
    //         const ImageConfiguration(), "assets/images/car_pin.png")
    //     .then(
    //   (icon) {
    //     setState(() {
    //       markerIcon = icon;
    //     });
    //   },
    // );
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

  //? Trip Status
  CurrentTripStatus? currentTripStatus;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<TripsBloc, TripState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        //
        setState(() {
          currentTripStatus = state.status;
        });
        if (state.status == CurrentTripStatus.inProgress) {
          setState(() {
            markers.removeWhere((element) =>
                element.markerId == const MarkerId('student location'));

            Marker resultMarker = Marker(
              markerId: const MarkerId('destination location'),
              position: LatLng(
                  state.trip!.dropoffLatitude,
                  state.trip!
                      .dropoffLongitude), // Replace with your desired LatLng
            );
            markers.add(resultMarker);
          });
        } else if (state.status == CurrentTripStatus.completed) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              //
              contactParent(widget.studentModel.parentEmail!,
                  widget.studentModel.studentName);
            },
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            child: const Icon(Icons.sos),
          ),
          body: Stack(
            children: [
              GoogleMap(
                polylines: Set<Polyline>.of(polylines.values),
                markers: markers,
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: driverLocation ?? const LatLng(0, 0),
                  zoom: 14.0,
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
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: size.width * 0.085,
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.35),
                                child: studentDetails?.avatarURL != null &&
                                        studentDetails?.avatarURL != ""
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.065),
                                        child: Image.network(
                                          studentDetails!.avatarURL!,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.redAccent,
                                      ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                studentDetails?.studentName ?? "Passenger",
                                // "Student",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                          if (state.status == CurrentTripStatus.driverArriving)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Distance ${distanceAndDurationBetweenDriverAndStudent?.value1 ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  "Duration ${distanceAndDurationBetweenDriverAndStudent?.value2 ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          if (state.status == CurrentTripStatus.inProgress)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Distance ${distanceAndDurationBetweenDriverAndDestination?.value1 ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  "Duration ${distanceAndDurationBetweenDriverAndDestination?.value2 ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  )
                                ]),
                            padding: const EdgeInsets.all(10),
                            child: state.status == CurrentTripStatus.initial
                                ? InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(50),
                                    child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Cancel Trip"),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.close,
                                        ),
                                      ],
                                    ),
                                  )
                                : state.status ==
                                        CurrentTripStatus.driverArriving
                                    ? InkWell(
                                        onTap: () {
                                          BlocProvider.of<TripsBloc>(context)
                                              .add(DriverArrivedEvent());
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: const Text("Arrived"),
                                      )
                                    : state.status ==
                                            CurrentTripStatus.driverArrived
                                        ? InkWell(
                                            onTap: () {
                                              BlocProvider.of<TripsBloc>(
                                                      context)
                                                  .add(InProgressEvent());
                                            },
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: const Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text("Start Trip"),
                                              ],
                                            ),
                                          )
                                        : state.status ==
                                                CurrentTripStatus.inProgress
                                            ? InkWell(
                                                onTap: () {
                                                  BlocProvider.of<TripsBloc>(
                                                          context)
                                                      .add(
                                                          TripCompletedEvent());
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: const Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text("End Trip"),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox(
                                                child: Text("Trip Ended"),
                                              ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  )
                                ]),
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: Container(
                                        height: 500,
                                        color: Colors.white,
                                        child: state.trip == null
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : Column(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_downward_rounded,
                                                            color: Colors.red,
                                                          )),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 9,
                                                    child: StreamBuilder<
                                                        QuerySnapshot>(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection('trips')
                                                          .doc(state.trip!.id)
                                                          .collection(
                                                              'messages')
                                                          .orderBy('timestamp',
                                                              descending: true)
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else {
                                                          if (snapshot.data!
                                                              .docs.isEmpty) {
                                                            return const Text(
                                                                "No new messages");
                                                          } else {
                                                            return ListView
                                                                .builder(
                                                              reverse: true,
                                                              controller:
                                                                  _scrollController,
                                                              itemCount:
                                                                  snapshot
                                                                      .data!
                                                                      .docs
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                bool isSentByMe = snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        'sentBy'] ==
                                                                    state.trip!
                                                                        .driverId;
                                                                return Container(
                                                                  alignment: isSentByMe
                                                                      ? Alignment
                                                                          .centerRight
                                                                      : Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      Container(
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            8,
                                                                        horizontal:
                                                                            8),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .symmetric(
                                                                      horizontal:
                                                                          16.0,
                                                                      vertical:
                                                                          8.0,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: !isSentByMe
                                                                          ? Colors
                                                                              .blue
                                                                          : Colors
                                                                              .redAccent,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                    child: Text(
                                                                      snapshot
                                                                          .data!
                                                                          .docs[index]['message'],
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            20.0,
                                                                        color: !isSentByMe
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    // ...
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              controller:
                                                                  _chatController,
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            16.0),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width:
                                                                          1.0),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width:
                                                                          1.0),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0),
                                                                ),
                                                                hintText:
                                                                    'Type a message',
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.send,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'trips')
                                                                  .doc(state
                                                                      .trip!.id)
                                                                  .collection(
                                                                      'messages')
                                                                  .add({
                                                                'message':
                                                                    _chatController
                                                                        .text,
                                                                'timestamp': DateTime
                                                                        .now()
                                                                    .millisecondsSinceEpoch,
                                                                'sentBy': state
                                                                    .trip!
                                                                    .driverId,
                                                              });
                                                              _chatController
                                                                  .clear();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: const Icon(
                                Icons.chat,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(50),
                          //       boxShadow: const [
                          //         BoxShadow(
                          //           color: Colors.grey,
                          //           blurRadius: 3,
                          //           spreadRadius: 1,
                          //         )
                          //       ]),
                          //   padding: const EdgeInsets.all(10),
                          //   child: InkWell(
                          //     onTap: () {},
                          //     borderRadius: BorderRadius.circular(50),
                          //     child: const Icon(
                          //       Icons.call,
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
