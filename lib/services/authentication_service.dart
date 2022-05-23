import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/pages/entry_pages/page_sign_in.dart';
import 'package:instagramgetx/pages/entry_pages/page_sign_up.dart';
import 'package:instagramgetx/services/hive_service.dart';
import 'package:instagramgetx/services/utils_service.dart';

class AuthenticationService {
  static final _auth = FirebaseAuth.instance;

  static Future<User?> signUpUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.updateDisplayName(name);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Utils.snackBar('Warning!', 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Utils.snackBar('Warning!', 'The account already exists.');
      } else {
        Utils.snackBar('Error!', 'Something went wrong, try again...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in signing up: $e');
      }
      Utils.snackBar('Error!', 'Something went wrong, try again...');
    }
    return null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (kDebugMode) {
        print(userCredential.user.toString());
      }
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.snackBar('Warning!', 'The email is not registered.');
      } else if (e.code == 'wrong-password') {
        Utils.snackBar('Warning!', 'Wrong password.');
      }
    }
    return null;
  }

  static void signOutUser() async {
    await _auth.signOut();
    HiveService.removeUid();
    Get.off(()=> const SignInPage());
    // Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  static void deleteAccount(BuildContext context) async {
    try {
      _auth.currentUser!.delete();
      HiveService.removeUid();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignUpPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Utils.snackBar('Warning!', 'The user must re-authenticate before this operation can be executed.');
      }
    }
  }
}