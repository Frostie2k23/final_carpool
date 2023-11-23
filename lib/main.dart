import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/trip/TripsBloc.dart';
import 'package:car_pool/screens/trip/trips_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'assets/concentric_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.ios,
      options: DefaultFirebaseOptions.currentPlatform);

  // if (kDebugMode) {
  //   const ipAddress = '192.168.8.164';
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator(ipAddress, 8080);
  //     await FirebaseAuth.instance.useAuthEmulator(ipAddress, 9099);
  //     FirebaseDatabase.instance.useDatabaseEmulator(ipAddress, 9000);
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //   }
  // }

  // Check if the user has completed registration
  //final bool userRegistered = await checkUserRegistration();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserDetailsCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => TripsBloc(
            firestore: FirebaseFirestore.instance,
          )..add(TripStartedEvent()),
          lazy: false,
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ConcentricTransitionScreen(),
        //routerDelegate: ,
      ),
    );
  }
}
