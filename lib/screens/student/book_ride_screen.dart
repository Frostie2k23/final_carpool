import 'package:car_pool/constants.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/student/confirm_ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

enum TripType {
  homeToUniversity,
  universityToHome,
}

class _BookRideScreenState extends State<BookRideScreen> {
  GoogleMapController? _controller;

  LatLng? homeLatLng;

  Set<Marker> markers = {};

  TripType tripType = TripType.homeToUniversity;

  /*
  void changeTripType(TripType tType) {
    setState(() {
      tripType = tType;
    });
  }*/
  void changeTripType(TripType tType, LatLng homeLatLng) {
    if (tType == TripType.homeToUniversity) {
      Marker resultMarker = Marker(
          markerId: const MarkerId('home location'), position: homeLatLng);
      setState(() {
        tripType = tType;
        markers.add(resultMarker);
        markers.removeWhere(
                (element) => element.markerId == const MarkerId('uni location'));
      });
      _animateCamera(homeLatLng);
    } else {
      Marker resultMarker = const Marker(
        markerId: MarkerId('uni location'),
        position: uniAddress,
      );
      setState(() {
        tripType = tType;
        markers.add(resultMarker);
        markers.removeWhere(
                (element) => element.markerId == const MarkerId('home location'));
      });
      _animateCamera(uniAddress);
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Book your ride"),
        ),
        body: BlocBuilder<UserDetailsCubit, UserDetailsState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (model) => Stack(
                children: [
                  GoogleMap(
                    markers: markers,
                    initialCameraPosition: CameraPosition(
                      target: model.latitude == null || model.longitude == null
                          ? const LatLng(10, 10)
                          : LatLng(
                              model.latitude!,
                              model.longitude!,
                            ),
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (model.latitude != null && model.longitude != null) {
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
                    },
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: size.height * 0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      height: size.height * 0.125,
                      width: size.width * 0.85,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tripType == TripType.homeToUniversity
                                    ? Icons.home_filled
                                    : Icons.school_rounded,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "To",
                                style: TextStyle(color: Colors.black),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Icon(
                                tripType != TripType.homeToUniversity
                                    ? Icons.home_filled
                                    : Icons.school_rounded,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                tripType == TripType.homeToUniversity
                                    ? "Your home address"
                                    : "University address",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: size.width * 0.50,
                                child: const Divider(
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                tripType != TripType.homeToUniversity
                                    ? "Your home address"
                                    : "University address",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              child: IconButton(
                                icon: const Icon(Icons.swap_vert_rounded),
                                onPressed: () {
                                  if (tripType == TripType.homeToUniversity) {
                                    //changeTripType(TripType.universityToHome);
                                    changeTripType(
                                        TripType.universityToHome,
                                        LatLng(
                                            model.latitude!, model.longitude!));
                                  } else {
                                    //changeTripType(TripType.homeToUniversity);
                                    changeTripType(
                                        TripType.homeToUniversity,
                                        LatLng(
                                            model.latitude!, model.longitude!));
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: MaterialButton(
                        minWidth: size.width - 40,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        color: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConfirmRide(
                                tripType: tripType,
                                //startLocation:
                                startLocation: tripType ==
                                        TripType.homeToUniversity
                                    ? LatLng(model.latitude!, model.longitude!)
                                    : uniAddress,
                                studentHome:
                                  LatLng(model.latitude!, model.longitude!),
                              ),
                            ),
                          );
                        },
                        child: const Text(
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
              orElse: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        ));
  }
}


//  void _getCurrentLocation() async {
//     try {
//       bool serviceEnabled;
//       LocationPermission permission;

//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return Future.error('Location services are disabled.');
//       }

//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return Future.error('Location permissions are denied');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         return Future.error(
//             'Location permissions are permanently denied, we cannot request permissions.');
//       }
//       _currentPosition = await Geolocator.getCurrentPosition();
//       if (_currentPosition != null) {
//         Marker resultMarker = Marker(
//           markerId: const MarkerId('current location'),
//           position: LatLng(_currentPosition!.latitude,
//               _currentPosition!.longitude), // Replace with your desired LatLng
//         );

//         markers.add(resultMarker);
//         if (mounted) {
//           setState(() {});
//         }
//         _animateCamera(
//             LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
