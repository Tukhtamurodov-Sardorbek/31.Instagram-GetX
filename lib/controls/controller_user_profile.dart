import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/hive_service.dart';
import 'package:instagramgetx/services/notification_http_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class UserController extends GetxController{
  var isLoading = false.obs;
  var profileOwner = UserModel(password: '', username: '', email: '').obs;
  var axisCount = 1.obs;
  var postsNumber = 0.obs;
  var posts = <Post>[].obs;
  var pageController = PageController().obs;
  var currentPage = 0.obs;


  late TabController tabController;
  var tabIndex = 0.obs;
  var heightTabBarView = 0.0.obs;
  List<Tab> tabs = <Tab>[
    const Tab(icon: Icon(Icons.grid_off, size: 24)),
    const Tab(icon: Icon(Icons.grid_view, size: 24)),
    const Tab(icon: Icon(Icons.grid_on_sharp, size: 24)),
  ];

  @override
  void onClose() {
    // TODO: implement onClose
    profileOwner.value = UserModel(password: '', username: '', email: '');
    postsNumber.value = 0;
    posts.clear();
    super.onClose();
  }

  void apiLoadUser(String uid) {
    isLoading.value = true;

    FirestoreService.loadUser(uid)
        .then((value) => {resLoadUser(value)});
  }

  void resLoadUser(UserModel userModel) {
    profileOwner.value = userModel;
    apiLoadPost();
  }

  void apiLoadPost() {
    isLoading.value = true;
    FirestoreService.loadPosts(profileOwner.value.uid)
        .then((value) => {resLoadPosts(value)});
  }

  void resLoadPosts(List<Post> _posts) {
    postsNumber.value = _posts.length;
    posts.value = _posts;
    isLoading.value = false;
    loadLikes(posts);
  }

  void apiPostLike(Post post) async {
    isLoading.value = true;

    await FirestoreService.likePost(post, true);

    post.isLiked = true;
    isLoading.value = false;

    UserModel myAccount = await FirestoreService.loadUser(null);
    UserModel someone = await FirestoreService.loadUser(post.uid);
    await HttpService.POST(HttpService.bodyLike(someone.deviceToken, myAccount.username, someone.username)).then((value) {
      if (kDebugMode) {
        print(value);
      }
    });
  }

  void apiPostUnlike(Post post) async {
    isLoading.value = true;

    await FirestoreService.likePost(post, false);
    post.isLiked = false;
    isLoading.value = false;
  }

  void shareFile(Post post, BuildContext context) async {
    isLoading.value = true;

    final box = context.findRenderObject() as RenderBox?;
    if (Platform.isAndroid || Platform.isIOS) {
      var response = await get(Uri.parse(post.image));
      final documentDirectory = (await getExternalStorageDirectory())?.path;
      File imgFile = File('$documentDirectory/flutter.png');
      imgFile.writeAsBytesSync(response.bodyBytes);
      Share.shareFiles([File('$documentDirectory/flutter.png').path],
          subject: 'Instagram',
          text: post.caption,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      Share.share('Hello, check your share files!',
          subject: 'URL File Share',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
    isLoading.value = false;
  }

  loadLikes(List<Post> allPosts) async {
    String uid = HiveService.getUID();
    // #get all liked posts
    var querySnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).collection('feeds').where("liked", isEqualTo: true).get();
    for (var element in querySnapshot.docs) {
      Post likedPost = Post.fromJson(element.data());
      for(var post in allPosts){
        if(post.id == likedPost.id){
          post.isLiked = true;
          // allPosts[allPosts.indexOf(post)].isLiked = true;
        }
      }
    }
  }

  void changeToList(){
    axisCount.value = 1;
  }

  void changeToGrid(){
    axisCount.value = 2;
  }

}