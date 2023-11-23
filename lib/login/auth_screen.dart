import 'package:car_pool/screens/driver/driver_details.dart';
import 'package:car_pool/screens/parent/parent_screen.dart';
import 'package:car_pool/screens/regular_profile_screen.dart';
import 'package:car_pool/screens/student/personal_details.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:car_pool/login/login_or_register_screen.dart';
import 'package:car_pool/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Listening to a user Account, type User
      body: StreamBuilder<User?>(
        //listening to the Firebase Auth data Stream for any changes in Login
        stream: AuthService().authStateChanges, // happens when user signs in
        //snapshot is the user data
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<Map<dynamic, dynamic>?>(
              future: currentUserClaims,
              builder: (context, claimsSnapshot) {
                if (claimsSnapshot.connectionState == ConnectionState.waiting) {
                  // Show loading spinner while waiting for the future to complete
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (claimsSnapshot.hasError) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text("Unexpected error"),
                    ),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Error: ${claimsSnapshot.error}'),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                              },
                              child: const Text("Logout"))
                        ],
                      ),
                    ),
                  );
                  // Handle error
                } else {
                  // Check  user role
                  final role = claimsSnapshot.data!['role'];
                  final basicDetailsAdded =
                      claimsSnapshot.data!['basic_details_added'] ?? false;
                  final driverDetailsAdded =
                      claimsSnapshot.data!['driver_details_added'] ?? false;
                  if (role == 'student') {
                    // student UI

                    if (basicDetailsAdded == true) {
                      return const RegularProfileScreen();
                    } else {
                      return const PersonalDetails();
                    }
                  } else if (role == 'parent') {
                    //parent
                    return const ParentScreen();
                  } else if (role == 'driver') {
                    if (basicDetailsAdded == true) {
                      if (driverDetailsAdded == true) {
                        // Show driver UI
                        return const HomeScreen();
                      } else {
                        return const DriverDetails();
                      }
                    } else {
                      return const PersonalDetails(
                        isDriver: true,
                      );
                    }
                  } else {
                    // Show driver UI

                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }
              },
            );
          } else {
            // if user is not logged in
            return const LoginOrRegisterScreen();
          }
        },
      ),
    );
  }

  Future<Map<dynamic, dynamic>?> get currentUserClaims async {
    final user = FirebaseAuth.instance.currentUser;

    // If refresh is set to true, a refresh of the id token is forced.
    final idTokenResult = await user?.getIdTokenResult(true);

    return idTokenResult?.claims;
  }
}
