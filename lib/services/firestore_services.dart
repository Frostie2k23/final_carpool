
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../classes/student.dart';

class FireStoreService
{

  final CollectionReference _studentsCollection =
  FirebaseFirestore.instance.collection('students');

  Future<void> addStudent(Student student, String avatarURL) async {
    try {
      await _studentsCollection.add({
        'studentID': student.studentID,
        'studentRole': student.studentRole,
        'studentAge': student.studentAge,
        'studentName': student.studentName,
        'majorDepartment': student.majorDepartment,
        'driversLicenseNumber': student.driversLicenseNumber,
        'carRegistrationNumber': student.carRegistrationNumber,
        'vehiclePlateNumber': student.vehiclePlateNumber,
        'vehicleColorType': student.vehicleColorType,
        'numberOfSeats': student.numberOfSeats,
        'emiratesIDNumber': student.emiratesIDNumber,
        'avatarURL': avatarURL,
      });
    } catch (e) {
      //print('Error adding student: $e');
      SnackBar(content: Text(e.toString()));
    }
  }


  Future<String> uploadImageAndGetDownloadUrl(String studentID, File avatarFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance.
      ref().child('avatars').child('$studentID.jpg');

      final UploadTask uploadTask = storageReference.putFile(avatarFile);
      await uploadTask.whenComplete(() => null);
      final imageURL = await storageReference.getDownloadURL();
      return imageURL;
    } catch (e) {
      return "error getting avatar";
    }
  }





  Stream<QuerySnapshot> getStudents() {
    return _studentsCollection.snapshots();
  }
  // use the above as:
    /*
   StreamBuilder<QuerySnapshot>(
  stream: firestoreService.getStudents(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      // Loading indicator while data is being fetched
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      // Handle any errors that occur
      return Text('Error: ${snapshot.error}');
    } else {
      // Data has been successfully fetched, display it
      final studentDocuments = snapshot.data.docs;

      return ListView.builder(
        itemCount: studentDocuments.length,
        itemBuilder: (context, index) {
          final studentData = studentDocuments[index].data() as Map<String, dynamic>;

          // Create a widget to display student information
          return ListTile(
            title: Text(studentData['studentName']),
            subtitle: Text(studentData['majorDepartment']),
            // Add more widgets to display other student properties
          );
        },
      );
    }
  },
)

* */

}