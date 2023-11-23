import 'package:car_pool/login/auth_screen.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ConcentricModel {
  String lottie;
  String text;

  ConcentricModel({required this.lottie, required this.text});
}

class ConcentricTransitionScreen extends StatefulWidget {
  const ConcentricTransitionScreen({super.key});

  @override
  State<ConcentricTransitionScreen> createState() =>
      _ConcentricTransitionScreenState();
}

class _ConcentricTransitionScreenState
    extends State<ConcentricTransitionScreen> {
  List<ConcentricModel> concentrics = [
    ConcentricModel(
        lottie:
            "https://lottie.host/5617abbb-4b84-4bcf-a8b0-927a40f623bf/bkN4NC27i2.json",
        text: "Connect with students"),
    ConcentricModel(
        lottie:
            "https://lottie.host/740b7a01-6e84-4306-8f2e-556f7ecf8225/2ci08dbsbS.json",
        text: "Share a ride"),
    ConcentricModel(
        lottie:
            "https://lottie.host/930f39c6-01d0-47ca-85c1-865cff1faa61/gWkrRSHKyy.json",
        text: "Welcome to AUS Carpool"),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ConcentricPageView(
          curve: Curves.fastOutSlowIn,
          pageSnapping: true,
          radius: 1800,
          reverse: true,
          onFinish: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()));
          },
          itemBuilder: (int value) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const AuthScreen()));
                  },
                  child: Container(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20),
                        child: Text(
                          "Skip",
                          style: GoogleFonts.robotoSlab(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 290,
                  width: 300,
                  child: LottieBuilder.network(
                    concentrics[value].lottie,
                    animate: true,
                  ),
                ),
                Text(
                  concentrics[value].text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  "${value + 1}/${concentrics.length}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300),
                ),
              ],
            );
          },
          colors: const <Color>[
            Colors.redAccent,
            Colors.cyanAccent,
            Colors.orange,
          ],
          itemCount: concentrics.length,
        ),
      ),
    );
  }
}
