import 'dart:async';

import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/login/auth_screen.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;

  const LoginScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService authService = AuthService();

  //constructor

  void showSuccessAlert() {
    if (mounted) {
      QuickAlert.show(
        context: context,
        text: "Success, Logged In",
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

  void myDelayScreenTransition() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AuthScreen()));
      }
    });
  }

  Future signIn() async {
    // final bool isValid = authService.isValidEmail(_emailController.text.trim());
    final bool isValid = EmailValidator.validate(_emailController.text.trim());

    try {
      if (isValid) {
        await authService.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim());
        //Once SignIn is successful, show AlertBox
        showSuccessAlert();
        myDelayScreenTransition(); //after box delay, then send to home-screen
      } else {
        showErrorAlert("Kindly, enter a valid  Email");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error During login';
      if (e.code == "user-not-found") {
        errorMessage = "You are not registered, please register and try again!";
      } else if (e.code == "wrong-password") {
        errorMessage = "Incorrect password";
      }
      showErrorAlert(errorMessage);
      setState(() {});
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
    _passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      TextSpan(text: "\nHello,"),
                      TextSpan(
                        text: "\nWelcome to AUSRide ",
                      ),
                      TextSpan(
                        text: "\nA CarPooling Application",
                      ),
                    ],
                  )),
                ),
              ),
              Lottie.network(
                'https://lottie.host/fb0e1387-33b2-4cfb-a201-bbe5641eee81/ZVGYEky523.json',
                animate: true,
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width / 1.8,
              ),
              const SizedBox(height: 20),
              MyTextField(
                  controller: _emailController,
                  hintText: "Enter a Valid AUS Email",
                  obscureText: false),
              const SizedBox(height: 10),
              MyTextField(
                  controller: _passController,
                  hintText: "Enter Password",
                  obscureText: true),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyText(
                        text: "Forgot Password?",
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () {
                      signIn();
                    },
                    child: const MyButton(
                      text: 'Sign In',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MyText(
                      text: "Not a member?",
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: widget.onTap,
                        child: const MyText(
                            text: " Register now",
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
