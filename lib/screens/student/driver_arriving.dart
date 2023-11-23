import 'dart:async';
import 'dart:ui' as ui;

import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/classes/student.dart';
import 'package:car_pool/constants.dart';
import 'package:car_pool/models/booking_request_model.dart';
import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/screens/trip/trips_state.dart';
import 'package:car_pool/services/chatService.dart';
import 'package:car_pool/services/emergency_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverArrivingScreen extends StatefulWidget {
  const DriverArrivingScreen(
      {super.key,
      required this.request,
      required this.tripModel,
      required this.studentModel});

  final BookingRequest request;
  final Trip tripModel;

  final Student studentModel;

  @override
  State<DriverArrivingScreen> createState() => _DriverArrivingScreenState();
}

class _DriverArrivingScreenState extends State<DriverArrivingScreen> {
  final CollectionReference chat =
      FirebaseFirestore.instance.collection('chat');

  String message = '';
  final _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool sendButtonLoading = false;

  // Initialize a database reference to the node you want to listen to
  late DatabaseReference nodeRef = FirebaseDatabase.instance
      .ref()
      .child('drivers')
      .child(widget.request.driverId);

  Student? driverDetails;

  // Attach an event listener to the node
  StreamSubscription? driverLocationsubscription;

  GoogleMapController? _controller;
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

  //! Driver average rating
  num? driverRating;

  StreamSubscription<QuerySnapshot>? _messagesStreamSubscription;

  _animateCamera(LatLng latLng) async {
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude), zoom: 16.5),
    ));
  }

  LatLng? driverLatLng;
  // LatLng? _currentPositionOfUser;

  void listenToDriverLocations() {
    driverLocationsubscription = nodeRef.onValue.listen((event) {
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
          final cTripStatus = context.read<TripsBloc>().state.status;
          if (cTripStatus == CurrentTripStatus.driverArriving) {
            getDirections(cTripStatus);
          } else if (cTripStatus == CurrentTripStatus.inProgress) {
            getDirections(cTripStatus);
          }

          print("mounted");
          print(driverLatLng);
          // setState(() {});
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

  void loadDriverDetails() async {
    final driverDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.request.driverId)
        .get();

    if (driverDoc.exists) {
      driverDetails = Student.fromJson(driverDoc.data()!);
      if (mounted) {
        setState(() {});
      }
    }
  }

  //! Review
  TextEditingController reviewTextEditingController = TextEditingController();

  double initialRating = 3;

  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  getDirections(CurrentTripStatus currentTripStatus) async {
    List<LatLng> polylineCoordinates = [];

    if (currentTripStatus == CurrentTripStatus.driverArriving) {
// result gets little bit late as soon as in video, because package // send http request for getting real road routes

      if (driverLatLng != null) {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleMapApiKey, //GoogleMap ApiKey
          PointLatLng(driverLatLng!.latitude,
              driverLatLng!.longitude), //first added marker
          PointLatLng(widget.request.pickupLocation.latitude,
              widget.request.pickupLocation.longitude), //last added marker
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
    } else if (currentTripStatus == CurrentTripStatus.inProgress) {
// result gets little bit late as soon as in video, because package // send http request for getting real road routes

      if (driverLatLng != null) {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleMapApiKey, //GoogleMap ApiKey
          PointLatLng(driverLatLng!.latitude,
              driverLatLng!.longitude), //first added marker
          PointLatLng(widget.request.dropoffLocation.latitude,
              widget.request.dropoffLocation.longitude), //last added marker
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

    setState(() {
      polylines[id] = polyline;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messagesStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listenToDriverLocations();

    loadDriverDetails();
    _scrollToBottom();

    _messagesStreamSubscription = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripModel.id)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _scrollToBottom();
    });

    addCustomIcon();

    setState(() {
      Marker resultMarker = Marker(
        markerId: const MarkerId('student location'),
        position:
            widget.request.pickupLocation, // Replace with your desired LatLng
      );
      markers.add(resultMarker);
    });

    getAverageRating(widget.request.driverId).then((value) {
      setState(() {
        driverRating = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(polylines.values.first);
    final size = MediaQuery.of(context).size;

    return BlocConsumer<TripsBloc, TripState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CurrentTripStatus.inProgress) {
          setState(() {
            markers.removeWhere((element) =>
                element.markerId == const MarkerId('student location'));

            Marker resultMarker = Marker(
              markerId: const MarkerId('destination location'),
              position: widget
                  .request.dropoffLocation, // Replace with your desired LatLng
            );
            markers.add(resultMarker);
          });
        }
      },
      builder: (context, state) {
        // print(polylines);
        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
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
                initialCameraPosition:
                    const CameraPosition(target: LatLng(0, 0)),
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    _controller = controller;
                  });
                  if (state.status == CurrentTripStatus.driverArriving ||
                      state.status == CurrentTripStatus.driverArrived ||
                      state.status == CurrentTripStatus.inProgress) {
                    if (driverLatLng?.latitude != null &&
                        driverLatLng?.longitude != null) {
                      Marker resultMarker = Marker(
                        markerId: const MarkerId('driver location'),
                        position: LatLng(
                            driverLatLng?.latitude ?? 0,
                            driverLatLng?.longitude ??
                                0), // Replace with your desired LatLng
                      );
                      markers.add(resultMarker);

                      _animateCamera(LatLng(driverLatLng?.latitude ?? 0,
                          driverLatLng?.longitude ?? 0));
                    }
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
                    onTap: () {},
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
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                driverDetails?.studentName ?? "Driver",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                driverDetails?.vehiclePlateNumber ?? "Loading",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                driverDetails?.vehicleColorType ?? "Loading",
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              // FutureBuilder<double>(
                              //   future: getAverageRating(driverDetails!.id),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState ==
                              //         ConnectionState.waiting) {
                              //       return const CircularProgressIndicator();
                              //     } else if (snapshot.hasError) {
                              //       return Text('Error: ${snapshot.error}');
                              //     } else {
                              //       double averageRating = snapshot.data ?? -1;
                              //       return StarRating(rating: averageRating);
                              //     }
                              //   },
                              // ),
                              StarRating(
                                  rating: driverRating?.toDouble() ?? -1),
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
                            child: state.status ==
                                        CurrentTripStatus.driverArriving ||
                                    state.status == CurrentTripStatus.initial
                                ? const Text("Driver arriving")
                                : state.status ==
                                        CurrentTripStatus.driverArrived
                                    ? const Text("Driver has arrived")
                                    : state.status ==
                                            CurrentTripStatus.inProgress
                                        ? const Text("Trip was started")
                                        : state.status ==
                                                CurrentTripStatus.completed
                                            ? InkWell(
                                                onTap: () {
                                                  showModalBottomSheet<void>(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(
                                                            bottom:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom,
                                                            top: 16.0,
                                                            left: 8.0,
                                                            right: 8.0),
                                                        child: Container(
                                                          height: 400,
                                                          color: Colors.white,
                                                          child: Column(
                                                            children: [
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child:
                                                                    IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_downward_rounded,
                                                                          color:
                                                                              Colors.red,
                                                                        )),
                                                              ),
                                                              const Text(
                                                                "Rate Your Ride",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20.0),
                                                              RatingBar.builder(
                                                                initialRating:
                                                                    initialRating,
                                                                minRating: 1,
                                                                direction: Axis
                                                                    .horizontal,
                                                                allowHalfRating:
                                                                    true,
                                                                itemCount: 5,
                                                                itemPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            4.0),
                                                                itemBuilder:
                                                                    (context,
                                                                            _) =>
                                                                        const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                ),
                                                                onRatingUpdate:
                                                                    (rating) {
                                                                  print(rating);
                                                                  setState(() {
                                                                    initialRating =
                                                                        rating;
                                                                  });
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 20.0),
                                                              TextField(
                                                                controller:
                                                                    reviewTextEditingController,
                                                                minLines: 4,
                                                                maxLines: 4,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .multiline,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  hintText:
                                                                      "Write your review here",
                                                                  hintStyle:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        16.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 40.0),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          25.0),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      //
                                                                      if (state
                                                                              .trip !=
                                                                          null) {
                                                                        addRating(
                                                                            state.trip!.driverId,
                                                                            state.trip!.id,
                                                                            state.trip!.passengerId,
                                                                            initialRating,
                                                                            reviewTextEditingController.text.trim());

                                                                        context
                                                                            .read<TripsBloc>()
                                                                            .add(TripResetValuesCustomerEvent());

                                                                        Navigator.of(context).popUntil((route) =>
                                                                            route.isFirst);
                                                                      }
                                                                    },
                                                                    child:
                                                                        const MyButton(
                                                                      text:
                                                                          'Add Rating',
                                                                    ),
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
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: const Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text("Rate your ride"),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox(),
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
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
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
                                              child:
                                                  StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('trips')
                                                    .doc(widget.tripModel.id)
                                                    .collection('messages')
                                                    .orderBy('timestamp',
                                                        descending: true)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  } else {
                                                    if (snapshot
                                                        .data!.docs.isEmpty) {
                                                      return const Text(
                                                          "No new messages");
                                                    } else {
                                                      // return ListView.builder(
                                                      //   reverse: true,
                                                      //   controller:
                                                      //       _scrollController,
                                                      //   itemCount: snapshot
                                                      //       .data!.docs.length,
                                                      //   itemBuilder:
                                                      //       (context, index) {
                                                      //     return ListTile(
                                                      //       title: Text(snapshot
                                                      //               .data!
                                                      //               .docs[index]
                                                      //           ['message']),
                                                      //     );
                                                      //   },
                                                      // );
                                                      return ListView.builder(
                                                        reverse: true,
                                                        controller:
                                                            _scrollController,
                                                        itemCount: snapshot
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          bool isSentByMe = snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ['sentBy'] ==
                                                              widget.tripModel
                                                                  .passengerId;
                                                          return Container(
                                                            alignment: isSentByMe
                                                                ? Alignment
                                                                    .centerRight
                                                                : Alignment
                                                                    .centerLeft,
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
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
                                                                vertical: 8.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: !isSentByMe
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .redAccent,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                              ),
                                                              child: Text(
                                                                snapshot.data!
                                                                            .docs[
                                                                        index]
                                                                    ['message'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      20.0,
                                                                  color: !isSentByMe
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
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
                                                    const EdgeInsets.all(8.0),
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
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 1.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .red,
                                                                    width: 1.0),
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
                                                            .collection('trips')
                                                            .doc(widget
                                                                .tripModel.id)
                                                            .collection(
                                                                'messages')
                                                            .add({
                                                          'message':
                                                              _chatController
                                                                  .text,
                                                          'timestamp': DateTime
                                                                  .now()
                                                              .millisecondsSinceEpoch,
                                                          'sentBy': widget
                                                              .tripModel
                                                              .passengerId,
                                                        });
                                                        _chatController.clear();
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

  //! Rating

  final CollectionReference ratingsCollection =
      FirebaseFirestore.instance.collection('ratings');

  Future<void> addRating(String driverId, String rideId, String cusId,
      double rating, String review) async {
    return ratingsCollection
        .add({
          'driverId': driverId,
          'rideId': rideId,
          'rating': rating,
          'cusId': cusId,
          'review': review
        })
        .then((value) => print("Ride Added"))
        .catchError((error) => print("Failed to add ride: $error"));
  }

  Future<double> getAverageRating(String driverId) async {
    QuerySnapshot querySnapshot =
        await ratingsCollection.where('driverId', isEqualTo: driverId).get();
    if (querySnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var document in querySnapshot.docs) {
        totalRating += document['rating'];
      }
      return totalRating / querySnapshot.docs.length;
    } else {
      return -1;
    }
  }

  //!
}

class StarRating extends StatefulWidget {
  final double rating;

  const StarRating({super.key, required this.rating});

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        if (index < widget.rating) {
          return const Icon(Icons.star, color: Colors.yellow);
        } else {
          return const Icon(Icons.star_border, color: Colors.yellow);
        }
      }),
    );
  }
}
