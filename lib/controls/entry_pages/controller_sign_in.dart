import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/pages/page_home.dart';
import 'package:instagramgetx/services/authentication_service.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/hive_service.dart';
import 'package:instagramgetx/services/utils_service.dart';

class SignInController extends GetxController{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  var isHidden = true.obs;
  var isLoading = false.obs;
  var clearEmail = false.obs;
  var lastPressed = DateTime(0).obs;

  void signIn() async {
    emailFocus.unfocus();
    passwordFocus.unfocus();
    String email = emailController.text.trim().toString();
    String password = passwordController.text.trim().toString();

    isLoading.value = true;
    // update();

    if (email.isEmpty || password.isEmpty) {
      Utils.snackBar('Error', 'Fill in the fields, please!');
      isLoading.value = false;
      // update();
      return;
    }

    await AuthenticationService.signInUser(email, password)
        .then((value) => getFirebaseUser(value));
  }

  void getFirebaseUser(User? user) {
    if (user != null) {
      HiveService.storeUID(user.uid);
      apiUpdateUser();
      Get.off(() => const HomePage());
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
    isLoading.value = false;
    // update();
  }

  void apiUpdateUser() async {
    UserModel user = await FirestoreService.loadUser(null);
    user.deviceToken = HiveService.getToken();
    await FirestoreService.updateUser(user);
  }

  void clear(){
    clearEmail.value = false;
    emailController.clear();
    // update();
  }

  void onChangedFunction(){
    clearEmail.value = emailController.text.isNotEmpty;
    // update();
  }

  void visibility(){
    isHidden.value = !isHidden.value;
    // update();
  }

  void updateLastPressedTime(){
    lastPressed.value = DateTime.now();
    // update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Utils.initNotification();
  }
}
