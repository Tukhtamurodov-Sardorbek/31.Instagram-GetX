import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/notification_http_service.dart';

class SearchController extends GetxController{
  final searchController = TextEditingController().obs;
  final searchFocus = FocusNode().obs;
  var clearSearch = false.obs;
  var isLoading = false.obs;
  var isPressed = false.obs;
  var users = <UserModel>[].obs;


  void searchUserFromFirestore(String keyword) {
    isLoading.value = true;
    // update();

    FirestoreService.searchUsers(keyword)
        .then((value) => {respSearchUsers(value)});
  }

  void respSearchUsers(List<UserModel> _users) {
    users.value = _users;
    isLoading.value = false;
    // update();
  }

  void apiFollowUser(UserModel someone) async {
    isLoading.value = true;
    // update();

    await FirestoreService.followUser(someone);
    someone.isFollowed = true;
    isLoading.value = false;
    // update();

    UserModel myAccount = await FirestoreService.loadUser(null);
    await HttpService.POST(HttpService.bodyFollow(someone.deviceToken, myAccount.username, someone.username)).then((value) {
      if (kDebugMode) {
        print('******************************************************************');
        print(value);
        print('******************************************************************');
      }
    });
    await FirestoreService.storePostsInMyFeed(someone);

    isPressed.value = false;
    // update();
  }

  void apiUnfollowUser(UserModel someone) async {
    isLoading.value = true;
    // update();

    await FirestoreService.unfollowUser(someone);
    someone.isFollowed = false;
    isLoading.value = false;
    // update();

    await FirestoreService.removePostsFromMyFeed(someone);

    isPressed.value = false;
    // update();
  }

  void tapped(){
    searchFocus.value.unfocus();
    clearSearch.value = false;
    searchController.value.text = '';
    // update();
  }

  void changed(search){
    searchController.value.text.isEmpty
        ? searchFocus.value.unfocus()
        : null;
    clearSearch.value = searchController.value.text.isNotEmpty;
    searchUserFromFirestore(search);
  }

  void pressed(UserModel user){
    isPressed.value = true;
    // update();

    print('isPressed: $isPressed \t isFollowed: ${user.isFollowed}');
    if (user.isFollowed) {
      apiUnfollowUser(user);
    } else {
      apiFollowUser(user);
    }
    print('isPressed: $isPressed \t isFollowed: ${user.isFollowed}');
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    searchUserFromFirestore('');
  }

  @override
  void onClose() {
    // TODO: implement onClose
    searchController.value.dispose();
    searchFocus.value.dispose();
    super.onClose();
  }
}