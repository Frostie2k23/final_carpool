import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  //-----attributes------
  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance; //Creates a FirebaseAuth.instance

  //------constructor------

  //----Methods-----
  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r"[bg]000\d{5,}@aus\.edu");
    return regex.hasMatch(email);
  }

  // currentUser getter
  User? get currentUser => _firebaseAuth.currentUser;
  String? get displayName => _firebaseAuth.currentUser?.displayName;

  // authStateChanges getter
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Sign's a User In
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  //Register User
  Future<String> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    final user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return user.user!.uid;
  }

  //User Sign Out Method
  Future<void> signUserOut() async {
    await _firebaseAuth.signOut();
  }

  //save new user info
  // Future<void> saveUserInfo() async {}
}
