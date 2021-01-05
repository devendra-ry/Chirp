import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/models/user.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //get the instance of database
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return (user != null) ? User(uid: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      // sign in with email and password
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      // register with email and password
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      // Create a new document for the user with uid in users collection
      await DatabaseService(uid: user.uid)
          .createUserData(fullName, email, password);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      //remove all locally saved data
      await Helper.saveUserLoggedInSharedPreference(false);
      await Helper.saveUserEmailSharedPreference('');
      await Helper.saveUserNameSharedPreference('');

      //sign out the user
      return await _auth.signOut().whenComplete(() async {});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //reset password
  Future resetPassword(String email) async {
    try {
      final auth = FirebaseAuth.instance;
      auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
