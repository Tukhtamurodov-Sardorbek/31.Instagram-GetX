import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/services/utils_service.dart';

class HomeController extends GetxController{
  var pageController = PageController().obs;
  var currentPage = 0.obs;
  var lastPressed = DateTime(0).obs;

  initNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Message: ${message.notification.toString()}");
      }
      Utils.showLocalNotification(message, context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
  }

  void updateLastTime(){
    lastPressed.value = DateTime.now();
  }

  void changePage(int index){
    currentPage.value = index;
  }
}