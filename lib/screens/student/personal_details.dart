import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/login/auth_screen.dart';
import 'package:car_pool/screens/driver/driver_details.dart';
import 'package:car_pool/screens/regular_profile_screen.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key, this.isDriver = false});

  final bool isDriver;

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _studentRoleController = TextEditingController();
  final TextEditingController _studentAgeController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _majorDepartmentController = TextEditingController();

  Future<void> savePersonalDetails() async {}


  String? getCurrentUserEmail() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String? email = user?.email; // This will be null if there is no user or the user has no email

    return email?.split('@').first;
  }


  void showSuccessAlert() {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: "Personal details submitted !",
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





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80.0),
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
                    TextSpan(
                      text: "New to AUSRide,",
                    ),
                    TextSpan(text: "\nEnter your personal details. "),
                  ],
                )),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //Email
            MyTextFormField(
              controller: _studentIDController,
              hintText: 'Enter your student ID',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              obscureText: false,
              validator: (String? value) {
                String? currentUserEmailPrefix  = getCurrentUserEmail();
                if (_studentIDController.text.isEmpty) {
                  return "Please enter your student ID";
                }
                else if(_studentIDController.text.toString() !=  currentUserEmailPrefix)
                {
                    return "Entered ID does not match, exclude aus.edu ";
                }
                return null;
                //else {return null;}
              },
            ),
            const SizedBox(
              height: 20,
            ),
            MyTextFormField(
              controller: _studentNameController,
              hintText: 'Enter your name',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_studentNameController.text.isEmpty) {
                  return 'Name cannot be Empty';
                }
                return null; // implies validation has passed
              },
              obscureText: false,
            ),

            const SizedBox(height: 20,),

            /*MyTextFormField(
                controller: _studentRoleController,
                hintText: 'Enter your student standing',
                autoValidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (_studentRoleController.text.isEmpty) {
                    return 'Please enter your student standing';
                  }
                  return null; // implies validation has passed
                },
                obscureText: false
            ),*/

            MyTextFormFieldPopMenu(
                controller: _studentRoleController,
                hintText: 'Please select your student standing',
                autoValidateMode: AutovalidateMode.onUserInteraction,
                obscureText: false,
                popUpMenuButton:PopupMenuButton(
                  enabled: true,
                  //color: Colors.redAccent.shade100,
                  elevation: 15,
                  enableFeedback: true,
                  shadowColor: Colors.redAccent,
                  onSelected: (String value) {
                    setState(() {
                      _studentRoleController.text =
                          value; //update the controller text
                    });
                  },
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  icon: const FaIcon(
                    FontAwesomeIcons.caretDown,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  itemBuilder: (BuildContext context) {
                    return ['Freshmen', 'Sophomore','Juniors','Senior']
                        .map((String userType) {
                      return PopupMenuItem<String>(
                        value: userType,
                        child: Text(
                          userType,
                          style: GoogleFonts.robotoSlab(),
                        ),
                      );
                    }).toList();
                  },
                ), validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please select your student standing';
              }
              // No additional validation needed since the input is controlled by the PopupMenuButton
              return null;
            },
            ),

            /*MyTextField(
              controller: _studentRoleController,
              obscureText: false,
              readOnly: true,
              hintText: 'Choose Standing',
              popUpMenuButton: PopupMenuButton(
                enabled: true,
                //color: Colors.redAccent.shade100,
                elevation: 15,
                enableFeedback: true,
                shadowColor: Colors.redAccent,
                onSelected: (String value) {
                  setState(() {
                    _studentRoleController.text =
                        value; //update the controller text
                  });
                },
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                icon: const FaIcon(
                  FontAwesomeIcons.caretDown,
                  size: 16,
                  color: Colors.redAccent,
                ),
                itemBuilder: (BuildContext context) {
                  return ['Freshmen', 'Sophomore','Senior']
                      .map((String userType) {
                    return PopupMenuItem<String>(
                      value: userType,
                      child: Text(
                        userType,
                        style: GoogleFonts.robotoSlab(),
                      ),
                    );
                  }).toList();
                },
              ),
            ),*/


            const SizedBox(height: 20,),

           /* MyTextFormField(
              isNumber: true,
              controller: _studentAgeController,
              hintText: 'Enter your age',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                //final _passwordTrimController = _passwordConfirmController.text.trim();
                if (_studentAgeController.text.isEmpty) {
                  return 'Age cannot be Empty';
                }

                return null; // implies validation has passed
              },
              obscureText: false,
            ),*/

            MyTextFormField(
              isNumber: true,
              controller: _studentAgeController,
              hintText: 'Enter your age',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                //final _passwordTrimController = _passwordConfirmController.text.trim();
                int? age = int.tryParse(value!);
                if (_studentAgeController.text.isEmpty) {
                  return 'Age cannot be Empty';
                }
                else if(age == null)
                {
                    return 'Enter a valid age';
                }
                else if (age < 16) {
                  return 'Age must be above 16';
                }

                return null; // implies validation has passed
              },
              obscureText: false,
            ),

            const SizedBox(height: 20,),
            /*MyTextFormField(
              controller: _majorDepartmentController,
              hintText: 'Enter your major department',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (_majorDepartmentController.text.isEmpty) {
                  return 'Department cannot be Empty';
                }
                return null; // implies validation has passed
              },
              obscureText: false,
            ),*/

            MyTextFormFieldPopMenu(
              controller: _majorDepartmentController,
              hintText: 'Enter your major department',
              autoValidateMode: AutovalidateMode.onUserInteraction,
              obscureText: false,
              popUpMenuButton:PopupMenuButton(
                enabled: true,
                //color: Colors.redAccent.shade100,
                elevation: 15,
                enableFeedback: true,
                shadowColor: Colors.redAccent,
                onSelected: (String value) {
                  setState(() {
                    _majorDepartmentController.text =
                        value; //update the controller text
                  });
                },
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                icon: const FaIcon(
                  FontAwesomeIcons.caretDown,
                  size: 16,
                  color: Colors.redAccent,
                ),
                itemBuilder: (BuildContext context) {
                  return ['CEN', 'CAS','CAAD','SBA']
                      .map((String userType) {
                    return PopupMenuItem<String>(
                      value: userType,
                      child: Text(
                        userType,
                        style: GoogleFonts.robotoSlab(),
                      ),
                    );
                  }).toList();
                },
              ), validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Enter your major department';
              }
              // No additional validation needed since the input is controlled by the PopupMenuButton
              return null;
            },
            ),


            const SizedBox(height: 40,),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    if (_studentIDController.text.trim() != "" &&
                        _studentRoleController.text.trim() != "" &&
                        _studentNameController.text.trim() != "" &&
                        _studentAgeController.text.trim() != "" &&
                        _majorDepartmentController.text.trim() != "") {
                      updatePersonalDetails(context);
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
            /*Align(
              alignment: Alignment.center,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    AuthService().signUserOut();
                  },
                  child: const MyButton(
                    text: 'Logout',
                  ),
                ),
              ),
            ),*/

          ],
        ),
      ),
    );
  }

  Future<void> updatePersonalDetails(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(AuthService().currentUser!.uid)
        .update({
      "studentID": _studentIDController.text.trim(),
      'studentName': _studentNameController.text.trim(),
      "studentRole": _studentRoleController.text.trim(),
      "majorDepartment": _majorDepartmentController.text.trim(),
      "basic_details_added": true,
    });

    showSuccessAlert();
    await Future.delayed(const Duration(seconds: 5));

    if (!context.mounted) return;

    if (widget.isDriver) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DriverDetails()));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false,
      );

      // Navigator.of(context).pop();

      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => const AuthScreen()));
    }
  }
}
