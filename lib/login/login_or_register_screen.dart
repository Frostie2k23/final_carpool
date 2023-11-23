import 'package:car_pool/login/login_screen.dart';
import 'package:car_pool/screens/register_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterScreen extends StatefulWidget
{
  const LoginOrRegisterScreen({super.key});

  @override
  State<LoginOrRegisterScreen> createState() => _LoginOrRegisterScreenState();


}

class _LoginOrRegisterScreenState extends State<LoginOrRegisterScreen>{

  //initally just want to show login page
  bool showLoginPage = true; // set to true at start

  //Simple toggle between register and login
  void toggleScreens () {
    setState(() {
      showLoginPage = !showLoginPage;
    });
}

  @override
  Widget build(BuildContext context) {

    if(showLoginPage)
      {
        return  LoginScreen(
          onTap: toggleScreens,);
      }
    else {
      return  RegisterScreen(
        onTap: toggleScreens,);
    }


  }

}
