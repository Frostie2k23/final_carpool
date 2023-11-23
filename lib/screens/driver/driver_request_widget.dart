import 'package:car_pool/models/driver_request.dart';
import 'package:car_pool/screens/driver/pickup_student.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverRequestWidget extends StatelessWidget {
  const DriverRequestWidget({super.key, required this.request});

  final DriverRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      child: SizedBox(
        height: 250,
        // color: Colors.red,
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              // color: Colors.green,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    // color: Colors.orange,
                    child: Row(children: [
                      Text(
                        "New request ${request.distance.toStringAsPrecision(2)} KM",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ]),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 30,
                    // color: Colors.orange,
                    child: Row(children: [
                      Text(
                        "Trip Distance ${request.tripDistance} ",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 30,
                    // color: Colors.orange,
                    child: Row(children: [
                      Text(
                        "Trip Duration ${request.tripDuration}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ]),
                  ),
                  const Divider(),
                  Expanded(
                    child: Container(
                      height: 30,
                      // color: Colors.blue,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          const Icon(Icons.square),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(request.tripType == 0 ? "Home" : "Univerisity")
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Container(
                      height: 30,
                      // color: Colors.blue,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          const Icon(Icons.circle),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(request.tripType == 0 ? "Univerisity" : "Home")
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(AuthService().currentUser!.uid)
                              .collection("requests")
                              .doc(request.requestId)
                              .update({'status': 'accepted'});

                          BlocProvider.of<TripsBloc>(context)
                              .add(DriverArrivingEvent());

                          context.read<UserDetailsCubit>().state.whenOrNull(
                            loaded: (model) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PickupStudent(
                                      request: request,
                                      studentModel: model,
                                    ),
                                  ));
                            },
                          );
                        },
                        child: const Text("Accept")),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(AuthService().currentUser!.uid)
                              .collection("requests")
                              .doc(request.requestId)
                              .update({'status': 'cancelled'});
                        },
                        child: const Text("Decline")),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
