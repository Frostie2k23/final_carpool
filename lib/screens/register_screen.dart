import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/classes/student.dart';
import 'package:car_pool/models/user_model.dart';
import 'package:car_pool/screens/regular_profile_screen.dart';
import 'package:car_pool/screens/student/personal_details.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'driver_profile_screen.dart';

/*
* // Should be simple and register user only, with email, pass ,name
// complete your profile screen should be called after, to handle other
// information.
// Here, i need to make sure of somethings:
* During Registrations, I have three users: Students,Faculty, parents
* Students + Faculty --> Make sure to sign them up with the @aus.edu
* domain check should be applied via FireAuth rules (firebase CLI needed?)
*
* Also: b000 and g000, leading characters may be useful in gender affirmation
* @aus.edu for domain.
*
* For parents, not sure????
*
* TextForm Field required
* ImagePicker Required for profile pic --> profile screen.
*
*
*
*
* */

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();

  final TextEditingController _userTypeController =
      TextEditingController(text: '');

  bool isPasswordObscured = true;

  void showSuccessAlert() {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: "Registered!",
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

  // signUP
  Future signUp() async {
    final bool isValid = authService.isValidEmail(_emailController.text.trim());
    try {
      if (isValid) {
        print("email is valid");
        final userId = await authService.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());

        final Student model = Student(
          id: userId,
          email: _emailController.text.trim(),
          type: _userTypeController.text.trim() == 'Driver'
              ? "driver"
              : "student",
          parentEmail: _parentEmailController.text.trim(),
        );

        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .set(model.toJson());
      } else {
        showErrorAlert("Kindly, enter a valid AUS Email");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error During Registration';
      if (e.code == "invalid-email") {
        errorMessage = "Invalid Email Format!";
      } else if (e.code == "email-already-in-use") {
        errorMessage = "email already exists";
      }
      showErrorAlert(errorMessage);
      //setState(() {}); leads to dispose error, called prior to dispostion.
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //dispose to save memory
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _userTypeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
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
                        text: "\nNew to AUSRide,",
                      ),
                      TextSpan(text: "\nRegister Now! "),
                    ],
                  )),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyTextField(
                        controller: _userTypeController,
                        obscureText: false,
                        readOnly: true,
                        hintText: 'Choose Driver or Non-Driver',
                        popUpMenuButton: PopupMenuButton(
                          enabled: true,
                          //color: Colors.redAccent.shade100,
                          elevation: 15,
                          enableFeedback: true,
                          shadowColor: Colors.redAccent,
                          onSelected: (String value) {
                            setState(() {
                              _userTypeController.text =
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
                            return ['Driver', 'Non-Driver']
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
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      //Email
                      MyTextFormField(
                          controller: _emailController,
                          hintText: 'Enter a Valid AUS Email',
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (_emailController.text.isEmpty) {
                              return 'Enter your AUS email';
                            } else if (!authService
                                .isValidEmail(_emailController.text.trim())) {
                              return 'Invalid Email Format!';
                            }
                            return null; // implies validation has passed
                          },
                          obscureText: false),
                      const SizedBox(
                        height: 20,
                      ),
                      //Email

                      MyTextFormField(
                          controller: _parentEmailController,
                          hintText: 'Enter your parents email',
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            // print(EmailValidator.validate(
                            //     _parentEmailController.text));
                            if (_parentEmailController.text.isEmpty) {
                              return 'Enter your parents email';
                            } else if (!EmailValidator.validate(
                                _parentEmailController.text)) {
                              return 'Invalid Email Format!';
                            }
                            else if(!value!.endsWith('@gmail.com') && !value.endsWith('@hotmail.com'))
                              {
                                return 'Email must be gmail.com '
                                    '/nor hotmail.com';
                              }
                            return null; // implies validation has passed
                          },
                          obscureText: false),

                      const SizedBox(
                        height: 20,
                      ),
                      //password
                      MyTextFormField(
                          controller: _passwordController,
                          hintText: 'Enter password',
                          iconButton: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordObscured = !isPasswordObscured;
                              });
                            },
                            icon: isPasswordObscured
                                ? const FaIcon(
                                    FontAwesomeIcons.eye,
                                    size: 16,
                                    color: Colors.redAccent,
                                  )
                                : const FaIcon(
                                    FontAwesomeIcons.eyeSlash,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                            alignment: Alignment.center,
                          ),
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            //final _passwordTrimController = _passwordConfirmController.text.trim();
                            if (_passwordController.text.isEmpty) {
                              return 'Field cannot be Empty';
                            }
                            else if(value!.length <6)
                            {
                                return 'Password cannot be less than 6 characters';
                            }

                            return null; // implies validation has passed
                          },
                          obscureText: isPasswordObscured),

                      const SizedBox(
                        height: 20,
                      ),

                      // confirm Password
                      MyTextFormField(
                          controller: _passwordConfirmController,
                          hintText: 'Confirm Password',
                          iconButton: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordObscured = !isPasswordObscured;
                              });
                            },
                            icon: isPasswordObscured
                                ? const FaIcon(
                                    FontAwesomeIcons.eye,
                                    size: 16,
                                    color: Colors.redAccent,
                                  )
                                : const FaIcon(
                                    FontAwesomeIcons.eyeSlash,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                            alignment: Alignment.center,
                          ),
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (_passwordConfirmController.text.isEmpty) {
                              return 'Field cannot be Empty';
                            } else if (_passwordConfirmController.text !=
                                _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null; // implies validation has passed
                          },
                          obscureText: isPasswordObscured),

                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate() &&
                                  _userTypeController.text.isNotEmpty) {
                                String selectedUserType =
                                    _userTypeController.text;
                                //print('Selected user type: $selectedUserType');

                                //navigation should be done here!
                                signUp();

                                if (selectedUserType == 'Driver') {
                                  //print('Navigating to DriverProfileScreen');
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PersonalDetails(
                                                isDriver: true,
                                              )));
                                } else if (selectedUserType == 'Non-Driver') {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const PersonalDetails()));
                                }
                              } else {
                                //print('Validation or user type check failed');
                                return showErrorAlert(
                                    'Error, a field might be empty!');
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
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: MyText(
                            text: " Or  ",
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 16)),
                    Expanded(
                      child: Divider(
                        thickness: 1.0,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MyText(
                      text: "Already a member?",
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: widget.onTap,
                        child: const MyText(
                            text: " Login now",
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
