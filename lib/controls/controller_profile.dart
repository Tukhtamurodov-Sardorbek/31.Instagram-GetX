import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/services/authentication_service.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/hive_service.dart';
import 'package:instagramgetx/services/storage_service.dart';
import 'package:instagramgetx/services/utils_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ProfileController extends GetxController{
  var isLoading = false.obs;
  var profileOwner = UserModel(password: '', username: '', email: '').obs;
  var postsNumber = 0.obs;
  // File? _image;
  var imagePath = ''.obs;
  var posts = <Post>[].obs;

  late StreamSubscription internetSubscription;
  var hasInternet = false.obs;

  late TabController tabController;
  var tabIndex = 0.obs;
  var heightTabBarView = 0.0.obs;
  List<Tab> tabs = <Tab>[
    const Tab(icon: Icon(Icons.grid_off, size: 24)),
    const Tab(icon: Icon(Icons.grid_view, size: 24)),
    const Tab(icon: Icon(Icons.grid_on_sharp, size: 24)),
  ];


  // #camera
  imageFromCamera() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    if(image != null){
      imagePath.value = image.path;
      // update();
    }
    changeProfilePhoto();
  }

  // #gallery
  imageFromGallery() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if(image != null){
      imagePath.value = image.path;
      // update();
    }
    changeProfilePhoto();
  }

  // #gallery or camera
  void mediaSource(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    imageFromGallery();
                    Get.back();
                    // Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imageFromCamera();
                    Get.back();
                    // Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  void changeProfilePhoto() {
    if (imagePath.isEmpty) return;
    print('PATH: $imagePath');
    isLoading.value = true;
    // update();
    StorageService.uploadUserImage(File(imagePath.value))
        .then((downLoadUrl) => apiUpdateUser(downLoadUrl!));
  }

  void apiUpdateUser(String downLoadUrl) async {
    UserModel userModel = await FirestoreService.loadUser(null);
    userModel.profileImageURL = downLoadUrl;
    await FirestoreService.updateUser(userModel);
    await FirestoreService.updateMyPostsInFollowersFeed(userModel);
    getUserFromFirestore();
  }

  void getUserFromFirestore() {
    isLoading.value = true;
    // update();
    print('<<<<< LOADING >>>>>');
    FirestoreService.loadUser(null).then((value) => showUserData(value));
  }

  void showUserData(UserModel user) {
    profileOwner.value.uid = user.uid;
    profileOwner.value.username = user.username;
    profileOwner.value.email = user.email;
    profileOwner.value.password = user.password;
    profileOwner.value.profileImageURL = user.profileImageURL;
    profileOwner.value.isFollowed = user.isFollowed;
    profileOwner.value.followings = user.followings;
    profileOwner.value.followers = user.followers;
    profileOwner.value.deviceId = user.deviceId;
    profileOwner.value.deviceType = user.deviceType;
    profileOwner.value.deviceToken = user.deviceToken;
    isLoading.value = false;
    // update();
    print('<<<<< PROFILE PAGE >>>>>');
    print('MY ID: ${profileOwner.value.uid} | MY NAME: ${profileOwner.value.username} | MY IMAGE: ${profileOwner.value.profileImageURL}');
  }

  void getPosts() {
    isLoading.value = true;
    FirestoreService.loadPosts(null).then((value) => {resLoadPosts(value)});
  }

  void resLoadPosts(List<Post> _posts) {
    if (_posts.isEmpty && hasInternet.value == true) {
      posts.value = [];
    } else if (_posts.isEmpty && hasInternet.value == false) {
      posts = RxList<Post>.from(HiveService.loadPosts());
    } else {
      posts.value = _posts;
      HiveService.storePosts(posts);
    }

    postsNumber.value = posts.length;
    heightTabBarView.value = postsNumber.value * 400;
    isLoading.value = false;
    // update();

    print('Index: ${tabController.index} \t Post: ${posts.length} Height: $heightTabBarView');
    print('Profile Page Number: ${posts.length} \t Posts: $postsNumber');
  }

  // #Sign out
  void logOut() async {
    var result = await Utils.dialog('Instagram', 'Confirm that you want to log out', false);
    if (result) {
      AuthenticationService.signOutUser();
      HiveService.removeUid();
      HiveService.removeFeed();
      HiveService.removePosts();
      HiveService.removeDeletedPosts();
    }
  }

  void actionRemovePost(Post post) async {
    var result = await Utils.dialog('Instagram',
        'Are you sure you want to remove this post?', false);
    if (result) {
      isLoading.value = true;
      // update();

      FirestoreService.removePost(post).then((value) => {getPosts()});
    }
  }

  @override
  void onInit() {
    internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          hasInternet.value = true;
          break;
        case InternetConnectionStatus.disconnected:
          hasInternet.value = false;
          break;
      }
    });
    getUserFromFirestore();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    internetSubscription.cancel();
    tabController.dispose();
    super.onClose();
  }
}