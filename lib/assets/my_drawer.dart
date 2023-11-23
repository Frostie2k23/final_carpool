import 'package:car_pool/assets/custom_widgets.dart';
import 'package:car_pool/screens/driver/redeem_points.dart';
import 'package:car_pool/screens/profile/cubit/user_details_cubit.dart';
import 'package:car_pool/screens/profile/profile_page.dart';
import 'package:car_pool/screens/session/session_input_page.dart';
import 'package:car_pool/screens/student/book_ride_screen.dart';
import 'package:car_pool/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MyDrawer extends StatefulWidget {
  User user = AuthService().currentUser!;

  final bool isDriver;

  MyDrawer({super.key, required this.user, this.isDriver = false});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.44,
      child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (model) {
              return Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 50),
                  child: ListView(
                    children: [
                      const SizedBox(height: 90,),
                      const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25.0),
                            child: MyText(
                                text: "AUSride",
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 38,

                            ),
                          )),

                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                            //shape: BoxShape.circle,
                            //color: Colors.redAccent,
                            // image: DecorationImage(image:AssetImage('lib/assets/images/Purrple_Cat_header.jpeg'), fit: BoxFit.cover,),
                            ),

                        accountName: Text(
                          model.studentName,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ), // need to get from Firestore
                        accountEmail: MyText(
                            text: widget.user.email!,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        /*currentAccountPicture: CircleAvatar(
                          child: ClipOval(
                            // later need to change to user image!!!!!!!, Firestore
                            child: model.avatarURL == null
                                ? Image.asset('lib/assets/images/cat.jpg')
                                : Image.network(model.avatarURL!),
                          ),
                        ),*/

                      ),

                      //Divider(color: Colors.black, thickness: 0.5,),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SessionInputPage(
                                        sessionTimes: model.sessionTimes,
                                      )));
                        },
                        enableFeedback: true,
                        leading: FaIcon(
                          FontAwesomeIcons.calendar,
                          color: Colors.redAccent[700],
                        ),
                        title: const MyText(
                            text: "Schedules",
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),

                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfilePage()));
                        },
                        enableFeedback: true,
                        leading: FaIcon(
                          FontAwesomeIcons.userGroup,
                          color: Colors.redAccent[700],
                        ),
                        title: const MyText(
                            text: "Profile",
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      //Divider(color: Colors.black, thickness: 0.5,),
                      if (!widget.isDriver)
                        ListTile(
                          onTap: () {
                            if (model.latitude == null ||
                                model.longitude == null) {
                              showErrorAlert(
                                  "You have to setup your home location .");
                            } else if (model.sessionTimes.isEmpty) {
                              showErrorAlert(
                                  "You have to setup your schedules");
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BookRideScreen()));
                            }
                          },
                          enableFeedback: true,
                          leading: FaIcon(
                            FontAwesomeIcons.carSide,
                            color: Colors.redAccent[700],
                          ),
                          title: const MyText(
                              text: "Book a ride",
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                      // Divider(color: Colors.black, thickness: 0.5,),
                      if (widget.isDriver)
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RedeemPoints()));
                          },
                          enableFeedback: true,
                          leading: FaIcon(
                            FontAwesomeIcons.store,
                            color: Colors.redAccent[700],
                          ),
                          title: const MyText(
                              text: "Reedem Points",
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),

                      // Divider(color: Colors.black, thickness: 0.5,),
                      // if (!widget.isDriver)
                      //   ListTile(
                      //     onTap: () {},
                      //     enableFeedback: true,
                      //     leading: FaIcon(
                      //       FontAwesomeIcons.star,
                      //       color: Colors.deepPurple[900],
                      //     ),
                      //     title: const MyText(
                      //         text: "Provide Ratings",
                      //         color: Colors.black,
                      //         fontWeight: FontWeight.w500,
                      //         fontSize: 16),
                      //   ),
                      //Divider(color: Colors.black, thickness: 0.5,),
                    ],
                  ),
                ),
              );
            },
            orElse: () {
              return Container(
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 50),
                  child: ListView(
                    children: [
                      const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25.0),
                            child: MyText(
                                text: "AUSride",
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 38),
                          )),

                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                            //shape: BoxShape.circle,
                            //color: Colors.redAccent,
                            // image: DecorationImage(image:AssetImage('lib/assets/images/Purrple_Cat_header.jpeg'), fit: BoxFit.cover,),
                            ),

                        accountName:
                            const Text(""), // need to get from Firestore
                        accountEmail: MyText(
                            text: widget.user.email!,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        currentAccountPicture: CircleAvatar(
                          child: ClipOval(
                            // later need to change to user image!!!!!!!, Firestore
                            child: Image.asset('lib/assets/images/cat.jpg'),
                          ),
                        ),
                      ),

                      //Divider(color: Colors.black, thickness: 0.5,),

                      //Divider(color: Colors.black, thickness: 0.5,),

                      //Divider(color: Colors.black, thickness: 0.5,),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
