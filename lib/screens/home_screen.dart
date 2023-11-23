import 'dart:async';
import 'dart:math';

import 'package:car_pool/assets/my_bottom_nav_bar.dart';
import 'package:car_pool/assets/my_drawer.dart';
import 'package:car_pool/classes/driverLocation.dart';
import 'package:car_pool/models/driver_request.dart';
import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/driver/driver_request_widget.dart';
import 'package:car_pool/screens/driver/pickup_student.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/screens/trip/trips_state.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:car_pool/screens/parent/parent_screen.dart';
import 'package:car_pool/screens/user_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

/*
*     ***Important things to take care of:
* 1) Route Management in routes
* 2) Provider?:
*
*
*
*
* */

class HomeScreen extends StatefulWidget {
  // Need constructor to pass data?
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //can get instance of the user:
  final _user = FirebaseAuth.instance.currentUser!;
  //List<ScreenHiddenDrawer> _screens = [];

  StreamSubscription<Position>? positionStream;

  final driverLocation = DriverLocation();

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  //start listening to the location of the driver
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 100,
  );

  final DatabaseReference driversRef =
      FirebaseDatabase.instance.ref().child('drivers');

  Future<void> startListeningToLocation() async {
    //check permissions first
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showErrorAlert('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showErrorAlert('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showErrorAlert(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    if (positionStream != null) {
      positionStream!.cancel();
    }
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      // print(position == null
      //     ? 'Unknown'
      //     : '${position.latitude.toString()}, ${position.longitude.toString()}');

      if (position != null) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(AuthService().currentUser!.uid)
            .update({'isAvailable': true});
        // Save the driver data in the Realtime Database

        driversRef.child(_user.uid).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'is_available': true
        });

        driverLocation
            .updateLocation(LatLng(position.latitude, position.longitude));
      }
    });
  }

  void stopTrip() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          elevation: 25,
          actions: [
            IconButton(
              onPressed: () {
                signUserOut();
              },
              icon: const FaIcon(
                FontAwesomeIcons.arrowRightFromBracket,
              ),
            )
          ],
        ),
        // bottomNavigationBar: const MyBottomNavBar(),
        drawer: MyDrawer(
          user: _user,
          isDriver: true,
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<TripsBloc, TripState>(
          listenWhen: (previous, current) => previous.trip != current.trip,
          listener: (context, state) {
            // TODO: implement listener
            // context.read<TripsBloc>().add(ListenToTripDocEvent());
          },
          builder: (context, tripState) {
            return Column(
              children: [
                BlocConsumer<UserDetailsCubit, UserDetailsState>(
                  listener: (context, state) {
                    state.whenOrNull(
                      loaded: (model) {
                        //
                        if (model.onATrip && model.currentTripId != null) {
                          FirebaseFirestore.instance
                              .collection("trips")
                              .doc(model.currentTripId)
                              .get()
                              .then((value) {
                            //
                            if (value.exists) {
                              context.read<TripsBloc>().add(
                                  OngoingTrip(Trip.fromJson(value.data()!)));
                            }
                          });
                        }
                      },
                    );
                  },
                  builder: (context, state) {
                    return state.maybeWhen(
                      loaded: (model) {
                        if (model.latitude == null || model.longitude == null) {
                          return const SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                "You have to setup your home location first to accept new requests.",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        } else {
                          if (model.isAvailable) {
                            startListeningToLocation();
                          }

                          if (!model.onATrip || model.currentTripId == null) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Switch(
                                        value: model.isAvailable,
                                        onChanged: (val) {
                                          if (val) {
                                            startListeningToLocation();
                                          } else {
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(AuthService()
                                                    .currentUser!
                                                    .uid)
                                                .update({'isAvailable': false});
                                            driversRef.child(_user.uid).update(
                                                {'is_available': false});
                                            positionStream?.cancel();
                                          }
                                        }),
                                    Text(model.isAvailable
                                        ? "You are online"
                                        : "You are offline"),
                                  ],
                                ),
                                if (model.isAvailable)
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(_user.uid)
                                        .collection("requests")
                                        .where('status', isEqualTo: 'pending')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.active) {
                                        if (snapshot.data != null) {
                                          // print(snapshot.data!.docs);
                                          if (snapshot.data!.docs.isNotEmpty) {
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                DriverRequest request =
                                                    DriverRequest.fromJson(
                                                        snapshot.data!
                                                                .docs[index]
                                                                .data()
                                                            as Map<String,
                                                                dynamic>);
                                                // return Card(
                                                //   child: ListTile(
                                                //     title: const Text("New request"),
                                                //     subtitle: Text(
                                                //         "Trip Types : ${request.tripType == 0 ? "Home to univerisity" : "Univerisity to Home"}"),
                                                //   ),
                                                // );
                                                return DriverRequestWidget(
                                                    request: request);
                                              },
                                            );
                                          } else {
                                            return const SizedBox(
                                                height: 200,
                                                child: Center(
                                                  child: Text(
                                                    "You don't have any new requests",
                                                  ),
                                                ));
                                          }
                                        } else {
                                          return const SizedBox(
                                              height: 200,
                                              child: Text(
                                                "Unexpected error occured . Please try again later",
                                              ));
                                        }
                                      } else {
                                        return const SizedBox(
                                            height: 200,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ));
                                      }
                                    },
                                  ),
                                if (!model.isAvailable)
                                  const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Text(
                                          "You have to go online to see new requests",
                                        ),
                                      ))
                              ],
                            );
                          } else {
                            return Container(
                                alignment: Alignment.center,
                                height: 400,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("You are crurrently on a trip"),
                                    ElevatedButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(AuthService()
                                                  .currentUser!
                                                  .uid)
                                              .collection("requests")
                                              .where('status',
                                                  isEqualTo: 'accepted')
                                              .orderBy('time', descending: true)
                                              .limit(1)
                                              .get()
                                              .then((value) {
                                            //
                                            context
                                                .read<UserDetailsCubit>()
                                                .state
                                                .whenOrNull(
                                              loaded: (model) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PickupStudent(
                                                        request: DriverRequest
                                                            .fromJson(value
                                                                .docs.first
                                                                .data()),
                                                        studentModel: model,
                                                      ),
                                                    ));
                                              },
                                            );
                                          });
                                          //
                                        },
                                        child: const Text("Go to trip")),
                                    // ElevatedButton(
                                    //     style: ElevatedButton.styleFrom(
                                    //       backgroundColor: Colors.red,
                                    //     ),
                                    //     onPressed: () {
                                    //       stopTrip();
                                    //     },
                                    //     child: const Text("Stop Trip"))
                                  ],
                                ));
                          }
                        }
                      },
                      orElse: () => Row(
                        children: [
                          Switch(value: false, onChanged: (val) {}),
                          const Text("You are offline"),
                        ],
                      ),
                    );
                  },
                ),
                //Container(color: Colors.redAccent, width: 120, height: 120),
                // ListTile(),
              ],
            );
          },
        ));

    //different menu
    /*return Scaffold(
      backgroundColor: Colors.lightBlue,

      body: Column(
        children: [
          Expanded(
              child: HiddenDrawerMenu(
                initPositionSelected: 0,
                screens: [
                  ScreenHiddenDrawer(
                      ItemHiddenMenu(name: 'Profile', baseStyle: TextStyle(), selectedStyle: TextStyle()),
                      UserProfileScreen()),
                  ScreenHiddenDrawer(
                      ItemHiddenMenu(name: 'Parents', baseStyle: TextStyle(), selectedStyle: TextStyle()),
                      ParentScreen()),
              ],
                backgroundColorMenu: Colors.blue,
               // slidePercent: 50.0,
                //verticalScalePercent: 80.0,
               // contentCornerRadius: 10.0,
               // isDraggable: true,
              ),
          ),
          MyBottomNavBar(),
        ],
      ),


    );*/
  }
}
