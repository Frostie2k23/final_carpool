import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25.0),
          child: GNav(
            padding: const EdgeInsets.all(12),
            gap: 15, // This already sets a gap between the items
            mainAxisAlignment: MainAxisAlignment.center,
            tabBackgroundColor: Colors.lightBlue.shade50,
            tabBorderRadius: 12,
            tabActiveBorder: Border.all(color: Colors.deepPurple),
            tabMargin: const EdgeInsets.symmetric(horizontal: 25),
            tabs: [
              GButton(
                icon: Icons.apps_rounded,
                text: ' home',
                borderRadius: BorderRadius.circular(25),
              ),
              // GButton(
              //   icon: FontAwesomeIcons.map,
              //   borderRadius: BorderRadius.circular(25),
              //   text: ' map',
              // ),
              // GButton(
              //   icon: FontAwesomeIcons.comments,
              //   borderRadius: BorderRadius.circular(25),
              //   text: ' chat',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
