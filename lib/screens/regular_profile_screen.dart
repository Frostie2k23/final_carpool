import 'package:car_pool/assets/my_bottom_nav_bar.dart';
import 'package:car_pool/assets/my_drawer.dart';
import 'package:car_pool/login/auth_screen.dart';
import 'package:car_pool/models/booking_request_model.dart';
import 'package:car_pool/models/trip_model.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/student/book_ride_screen.dart';
import 'package:car_pool/screens/student/driver_arriving.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/screens/trip/trips_state.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// After Registering,
class RegularProfileScreen extends StatefulWidget {
  const RegularProfileScreen({super.key});

  @override
  State<RegularProfileScreen> createState() => _RegularProfileScreenState();
}

class _RegularProfileScreenState extends State<RegularProfileScreen> {
  //can get instance of the user:
  final _user = FirebaseAuth.instance.currentUser!;
  //List<ScreenHiddenDrawer> _screens = [];

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
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<TripsBloc, TripState>(
          listenWhen: (previous, current) => previous.trip != current.trip,
          listener: (context, state) {
            // context.read<TripsBloc>().add(ListenToTripDocEvent());
            if (state.trip?.status == TripStatus.driverArrived) {
              context.read<TripsBloc>().add(DriverArrivedToCustomerEvent());
            } else if (state.trip?.status == TripStatus.inProgress) {
              context.read<TripsBloc>().add(TripInProgressCustomerEvent());
            } else if (state.trip?.status == TripStatus.completed) {
              context.read<TripsBloc>().add(TripCompletedCustomerEvent());
            }
          },
          builder: (context, state) {
            if (state.status == CurrentTripStatus.inProgress ||
                state.status == CurrentTripStatus.driverArriving ||
                state.status == CurrentTripStatus.driverArrived) {
              return Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Currently On a Trip'),
                    ElevatedButton(
                        onPressed: () {
                          //

                          if (state.trip != null) {
                            FirebaseFirestore.instance
                                .collection("requests")
                                .where('userId',
                                    isEqualTo: AuthService().currentUser!.uid)
                                .orderBy('bookingTime', descending: true)
                                .limit(1)
                                .get()
                                .then((value) {
                              if (value.docs.isNotEmpty) {
                                final request = BookingRequest.fromJson(
                                    value.docs.first.data());

                                context
                                    .read<TripsBloc>()
                                    .add(ListenToTripDocEvent());

                                context
                                    .read<UserDetailsCubit>()
                                    .state
                                    .whenOrNull(
                                  loaded: (model) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DriverArrivingScreen(
                                          request: request,
                                          tripModel: state.trip!,
                                          studentModel: model,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            });
                          } else {
                            print("trip is not loaded");
                          }
                        },
                        child: const Text("Go to trip")),
                  ],
                ),
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('HomeScreen'),
                    Text("Signed as: ${_user.email!}"),
                  ],
                ),
              );
            }
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
