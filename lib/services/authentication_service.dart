import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import foundation for kDebugMode

class AuthService {
  // Get the instance of database
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on FirebaseUser (Corrected)
  // This method was redundant and incorrect. We can directly use User.
  // The User object from Firebase already has the properties we need.

  // Sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in with email and password
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user; // User can be null

      if (user != null && user.emailVerified) {
        return user; // Return the User object directly
      } else if (user != null && !user.emailVerified) {
        // Handle unverified email
        if (kDebugMode) {
          print("Email not verified");
        }
        return "not verified"; // Indicate email not verified
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  // Register with email and password
  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      // Register with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user; // User can be null
      if (user != null) {
        await user.sendEmailVerification();
        // Create a new document for the user with uid in users collection
        await DatabaseService(uid: user.uid)
            .createUserData(fullName, email, password);
        return user; // Return the User object directly
      }
      return null;

    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      // Remove all locally saved data
      await Helper.saveUserLoggedInSharedPreference(false);
      await Helper.saveUserEmailSharedPreference('');
      await Helper.saveUserNameSharedPreference('');

      // Sign out the user
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  // Reset password
  Future resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true; // Indicate success
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }
}