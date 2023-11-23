import 'package:car_pool/classes/student.dart';
import 'package:car_pool/screens/parent/monitor_student_screen.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/*
 Options to incorporate parents:
* Invitation-based Access: University students or faculty can send invites to their parents,
* granting them access to the application.
*
* OR
*
Temporary Passcode: Generate a time-limited passcode that can be used for login.
*
*
* OR
View-Only Public URLs: Generate view-only URLs that parents can use to
* access specific information without logging in.
*
*
*
* */

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  bool childCurrentlyOnATrip = false;
  String? currentTripID;

  String? studentId;

  Future<void> getUserByParentEmail(String parentEmail) async {
    QuerySnapshot querySnapshot = await usersCollection
        .where('parent_email', isEqualTo: parentEmail)
        .get();

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document found

      final studentIdL = querySnapshot.docs.first.id;

      FirebaseFirestore.instance
          .collection("users")
          .doc(studentIdL)
          .snapshots()
          .map(
              (event) => Student.fromJson(event.data() as Map<String, dynamic>))
          .listen((event) {
        //
        if (event.onATrip && event.currentTripId != null) {
          setState(() {
            childCurrentlyOnATrip = true;
            currentTripID = event.currentTripId;
            studentId = studentIdL;
          });
        } else {
          setState(() {
            childCurrentlyOnATrip = false;
            currentTripID = null;
            studentId = null;
          });
        }
      });
    } else {
      // No documents found with the given parent email
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserByParentEmail(AuthService().currentUser!.email!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Welcome Parent"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AuthService().signUserOut();
        },
        tooltip: "Logout",
        child: const Icon(FontAwesomeIcons.signOut),
      ),
      body: Center(
        child: childCurrentlyOnATrip
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  if (studentId != null && currentTripID != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MonitorStudentScreen(
                                  studentId: studentId!,
                                  tripId: currentTripID!,
                                )));
                  }
                },
                child: const Text("Monitor Student"))
            : const Text(
                "Student currently not on a trip",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
