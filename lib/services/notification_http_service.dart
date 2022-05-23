import 'dart:convert';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/services/hive_service.dart';

class HttpService {
  static String BASE = 'fcm.googleapis.com';
  static String API_SEND = '/fcm/send';

  static Map<String, String> headers = {
    'Authorization': 'key=AAAAWi6KU70:APA91bHW936_8izQjoEEBkYNC68h3IVEvr8VFQ1uUVnmVhu6pv6sM8ndbXSJKeVODRnYlu74Qpxs-ZPJA4sf2GMGt7uWV6v0liE-anNZtjMyRLte43_9hx9TxnZ_SqrHV3LeVUdMJTKV',
    'Content-Type': 'application/json'
  };

  static Future<String?> POST(Map<String, dynamic> body) async {
    var uri = Uri.https(BASE, API_SEND);
    var response = await post(uri, headers: headers, body: jsonEncode(body));
    if(response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  // static Future<String> loadMe() async {
  //   String uid = HiveService.getUID();
  //   var value = await FirebaseFirestore.instance.collection("users").doc(uid).get();
  //   UserModel user = UserModel.fromJson(value.data()!);
  //   return user.username;
  // }

  static Map<String, dynamic> bodyFollow(String fcmToken, String username, String myName) {
    Map<String, dynamic> body = {};
    body.addAll({
      'notification': {
        'title': 'Instagram ($myName)',
        'body': '$username started following you'
      },
      'registration_ids': [fcmToken],
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    });
    return body;
  }

  static Map<String, dynamic> bodyLike(String fcmToken, String username, String myName) {
    Map<String, dynamic> body = {};
    body.addAll({
      'notification': {
        'title': 'Instagram ($myName)',
        'body': '$username liked your post'
      },
      'registration_ids': [fcmToken],
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    });
    return body;
  }
}