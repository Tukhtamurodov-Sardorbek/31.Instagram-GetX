import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/pages/page_home.dart';
import 'package:instagramgetx/services/authentication_service.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/hive_service.dart';
import 'package:instagramgetx/services/utils_service.dart';

class SignUpController extends GetxController{
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  var clearName = false.obs;
  var clearEmail = false.obs;
  var isLoading = false.obs;
  var isHidden1 = true.obs;
  var isHidden2 = true.obs;
  var lastPressed = DateTime(0).obs;

  void signUp() async{
    nameFocus.unfocus();
    emailFocus.unfocus();
    passwordFocus.unfocus();
    confirmPasswordFocus.unfocus();

    isLoading.value = true;
    // update();

    String username = nameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String confirmPassword = confirmPasswordController.text.toString().trim();
    if(username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty){
      Utils.snackBar('Error', 'Fill in the fields, please!');
      isLoading.value = false;
      // update();
      return;
    }
    else if (Utils.validateEmail(email) == false) {
      Utils.snackBar('Error', 'Enter a valid email address, please!');
      isLoading.value = false;
      // update();
      return;
    }
    else if (Utils.validatePassword(password) == false) {
      Utils.snackBar('Error', 'Password must contain at least one upper case, one lower case, one digit, one special character and be at least 8 characters in length');
      isLoading.value = false;
      // update();
      return;
    }
    else if(password != confirmPassword){
      Utils.snackBar('Error', 'Confirm password correctly, please!');
      isLoading.value = false;
      // update();
      return;
    }

    UserModel user = UserModel(username: username, email: email, password: password);
    await AuthenticationService.signUpUser(username, email, password)
        .then((value) => getFirebaseUser(user, value));
  }

  void getFirebaseUser(UserModel userModel, User? user) {
    if (user != null) {
      HiveService.storeUID(user.uid);
      FirestoreService.storeUser(userModel).then((value) => Get.off(() => const HomePage()));
      // Navigator.pushReplacementNamed(context, HomePage.id));
    } else {
      Utils.snackBar('Error', 'Check your data, please!');
    }
    isLoading.value = false;
    // update();
  }

  void updateLastPressedTime(){
    lastPressed.value = DateTime.now();
    // update();
  }

  void clear(){
    clearName.value = false;
    nameController.clear();
    // update();
  }

  void updateName(){
    clearName.value = nameController.value.text.isNotEmpty;
    // update();
  }

  void updateEmail(){
    clearEmail.value = emailController.value.text.isNotEmpty;
    // update();
  }

  void updatePassword1(){
    isHidden1.value = !isHidden1.value;
    // update();
  }

  void updatePassword2(){
    isHidden2.value = !isHidden2.value;
    // update();
  }


}