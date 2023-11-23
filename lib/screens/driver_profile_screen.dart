
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../classes/student.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});
  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _studentRole = "Driver";
  late final String _studentAge = "";
  final String _studentName = " ";
  final String _majorDepartment = " ";
  final String _driversLicenseNumber = "";
  final String _carRegistrationNumber = "";
  final String _vehiclePlateNumber = "";
  final String _vehicleColorType = "";
  final int _numberOfSeats = 0;
  final String _emiratesIDNumber = "";
  late final File _selectedImage; // To store the selected image file

  // Function to pick an image from the device
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to submit the registration form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, you can proceed to save the data to Firestore
      // Create a Student.driver instance and save data to Firestore
      final driverStudent = Student.driver(
        studentRole: _studentRole,
        studentAge: _studentAge,
        studentName: _studentName,
        majorDepartment: _majorDepartment,
        driversLicenseNumber: _driversLicenseNumber,
        carRegistrationNumber: _carRegistrationNumber,
        vehiclePlateNumber: _vehiclePlateNumber,
        vehicleColorType: _vehicleColorType,
        numberOfSeats: _numberOfSeats,
        emiratesIDNumber: _emiratesIDNumber, studentID: null,
      );

      // Upload the selected image to Firebase Storage (use the _selectedImage file)
      // Then, save the download URL to Firestore along with other data

      // Clear form fields and image selection
      _formKey.currentState?.reset();
      setState(() {
        _selectedImage = null;
      });

      // Show a success message or navigate to another screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Add form fields for all the student properties here
              // For example:
              TextFormField(
                decoration: InputDecoration(labelText: 'Student Age'),
                onChanged: (value) {
                  setState(() {
                    _studentAge = value;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your age.';
                  }
                  return null;
                },
              ),
              // Add more form fields for other properties

              // Photo Upload Button
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Photo'),
              ),
              // Display selected image (if any)
              if (_selectedImage != null) Image.file(_selectedImage),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */
