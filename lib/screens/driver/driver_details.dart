import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/login/auth_screen.dart';
import 'package:car_pool/screens/home_screen.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class DriverDetails extends StatefulWidget {
  const DriverDetails({super.key});

  @override
  State<DriverDetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final TextEditingController _driversLicenseNumberController =
      TextEditingController();
  final TextEditingController _carRegistrationNumberController =
      TextEditingController();
  final TextEditingController _vehiclePlateNumberController =
      TextEditingController();
  final TextEditingController _vehicleColorTypeController =
      TextEditingController();
  final TextEditingController _numberOfSeatsController =
      TextEditingController();
  final TextEditingController _emiratesIDNumberController =
      TextEditingController();

  void showSuccessAlert() {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: "Driver details submitted !",
        showConfirmBtn: false,
        type: QuickAlertType.success,
      );
    }
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

  Future<void> updateDriverDetails(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AuthService().currentUser!.uid)
        .update({
      "driversLicenseNumber": _driversLicenseNumberController.text.trim(),
      'emiratesIDNumber': _emiratesIDNumberController.text.trim(),
      "carRegistrationNumber": _carRegistrationNumberController.text.trim(),
      "vehiclePlateNumber": _vehiclePlateNumberController.text.trim(),
      "vehicleColorType": _vehicleColorTypeController.text.trim(),
      "numberOfSeats": int.parse(_numberOfSeatsController.text.trim()),
      "driver_details_added": true,
    });

    showSuccessAlert();
    await Future.delayed(const Duration(seconds: 5));
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 5,),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),

                child: RichText(
                    text: TextSpan(
                  style: GoogleFonts.robotoSlab(
                      color: Colors.redAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                  children: const <TextSpan>[
                    TextSpan(text: "\nPersonal and vehicle details"),
                  ],
                )),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //Email
            MyTextFormField(
              controller: _driversLicenseNumberController,
              hintText: "Your driver's license number",
              autoValidateMode: AutovalidateMode.onUserInteraction,
              obscureText: false,
              validator: (String? value) {
                if (_driversLicenseNumberController.text.isEmpty) {
                  return "License number cannot be empty";
                }
                // Regular expression for only digits
                RegExp digitPattern = RegExp(r'^\d+$');
                if (!digitPattern.hasMatch(value!)) {
                  return "License number must contain only digits";
                }
                else if (value.length < 5) {
                  return "License number must be at least 4 digits long";
                }
                else if (value.length > 9) {
                  return "License number is too long";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            MyTextFormField(
              controller: _emiratesIDNumberController,
              hintText: 'Enter your Emirates Id number',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_emiratesIDNumberController.text.isEmpty) {
                  return 'Emirates Id cannot be Empty';
                }
                RegExp pattern = RegExp(r'^\d{3}-\d{4}-\d{7}-\d{1}$');
                if (!pattern.hasMatch(value!)) {
                  return 'Invalid format. Format should be XXX-XXXX-XXXXXXX-X'
                      '\n Digits:3-4-7-1';
                }
                return null; // implies validation has passed
              },
              obscureText: false,
            ),
            const SizedBox(
              height: 20,
            ),
            MyTextFormField(
              controller: _carRegistrationNumberController,
              hintText: 'Enter vehicle registration number',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_carRegistrationNumberController.text.isEmpty) {
                  return 'Registration number cannot be Empty';
                }
                RegExp digitPattern = RegExp(r'^\d+$');
                if (!digitPattern.hasMatch(value!) || value.length < 6) {
                  return "number must be atleast 6 digits long & contain digits";
                }
                return null; // implies validation has passed
              },
              obscureText: false,
            ),

            const SizedBox(
              height: 20,
            ),

            MyTextFormField(
                controller: _vehiclePlateNumberController,
                hintText: 'Enter your vehicle plate number',
                autoValidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (_vehiclePlateNumberController.text.isEmpty) {
                    return 'Vehicle plate number cannot be empty';
                  }
                  // Regular expression for the format: digits-Region
                  //RegExp pattern = RegExp(r'^\d+-(Sharjah|Dubai|Abu Dhabi|Ajman|Fujairah|RAK|Umm Al Quwain)$');
                  RegExp pattern = RegExp(r'^[A-Z]-(SHARJAH|DUBAI|AD|AJMAN|FUJIRAH|RAK|UAQ)-\d+$');
                  if (!pattern.hasMatch(value!)) {
                    return 'Format should be Letter-Region-Number'
                        '\n(e.g., '
                        '\nA-SHARJAH|DUBAI|AD|AJMAN|FUJIRAH|RAK|UAQ-1234)';
                  }
                  return null; // implies validation has passed
                },
                obscureText: false),

            const SizedBox(
              height: 20,
            ),
            //password
            MyTextFormField(
              controller: _vehicleColorTypeController,
              hintText: 'Enter vehicle color',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                //final _passwordTrimController = _passwordConfirmController.text.trim();
                if (_vehicleColorTypeController.text.isEmpty) {
                  return 'Vehicle color cannot be Empty';
                }
                return null; // implies validation has passed
              },
              obscureText: false,
            ),

            const SizedBox(
              height: 20,
            ),
            MyTextFormField(
              isNumber: true,
              controller: _numberOfSeatsController,
              hintText: 'Enter number of seats of the vehicle',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_numberOfSeatsController.text.isEmpty) {
                  return 'Number of seats cannot be Empty';
                }
                // Regular expression for only digits
                RegExp digitPattern = RegExp(r'^\d+$');
                if (!digitPattern.hasMatch(value!)) {
                  return "Number of seats must contain only digits";
                }
                int numberOfSeats = int.parse(value!);
                if (numberOfSeats < 1 || numberOfSeats > 3) {
                  return "Number of seats must be between 1 and 3";
                }
                return null; // implies validation has passed
              },
              obscureText: false,
            ),

            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    if (_driversLicenseNumberController.text.trim() != "" &&
                        _emiratesIDNumberController.text.trim() != "" &&
                        _carRegistrationNumberController.text.trim() != "" &&
                        _vehiclePlateNumberController.text.trim() != "" &&
                        _vehicleColorTypeController.text.trim() != "" &&
                        _numberOfSeatsController.text.trim() != "") {
                      updateDriverDetails(context);
                    } else {
                      showErrorAlert('Error, a field might be empty!');
                    }
                  },
                  child: const MyButton(
                    text: 'Register',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
