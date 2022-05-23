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
import 'package:instagramgetx/services/utils_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FeedController extends GetxController {
  var isLoading = false.obs;
  var isSharing = false.obs;
  var posts = <Post>[].obs;

  void requestForFeed() {
    isLoading.value = true;
    FirestoreService.loadFeeds().then((value) => {getPosts(value)});
  }

  Future<List<Post>> loadFeed() async {
    isLoading.value = true;
    // // update();
    List<Post> posts = [];
    String uid = HiveService.getUID();
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('feeds')
        .orderBy("date", descending: true)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if (post.uid == uid) post.isMine = true;
      posts.add(post);
    }
    return posts;
  }

  void getPosts(List<Post> _posts) async {
    if (_posts.isEmpty) {
      // TODO:: if followed then get the posts otherwise delete from database
      String uid = HiveService.getUID();
      List<Post> storedPosts = HiveService.loadFeed();
      List<UserModel> followingUsers = [];
      List<Post> availablePosts = [];
      print('GETTING POSTS: Available Posts: ${storedPosts.length}');
      // #Get list of all followed users
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('followings')
          .get();
      for (var result in querySnapshot.docs) {
        UserModel followingUser = UserModel.fromJson(result.data());
        followingUsers.add(followingUser);
      }
      for (Post post in storedPosts) {
        for (UserModel user in followingUsers) {
          if (post.uid == user.uid && user.isFollowed) {
            availablePosts.add(post);
          }
        }
      }
      posts.value = availablePosts;
      followingUsers.clear();
      availablePosts.clear();
      storedPosts.clear();

      print('GOT POSTS: Available Posts: ${storedPosts.length}');
    } else {
      posts.value = _posts;
      HiveService.storeFeed(posts);
    }
    if (kDebugMode) {
      print('Number: ${posts.length} \t Posts: $posts');
    }

    isLoading.value = false;
  }

  void apiPostLike(Post post) async {
    isLoading.value = true;

    await FirestoreService.likePost(post, true);
    post.isLiked = true;
    isLoading.value = false;
    // update();

    UserModel myAccount = await FirestoreService.loadUser(null);
    if (post.uid != myAccount.uid) {
      UserModel someone = await FirestoreService.loadUser(post.uid);
      await HttpService.POST(HttpService.bodyLike(
              someone.deviceToken, myAccount.username, someone.username))
          .then((value) {
        if (kDebugMode) {
          print(value);
        }
      });
    }
  }

  void apiPostUnlike(Post post) async {
    isLoading.value = true;
    // update();

    await FirestoreService.likePost(post, false);
    post.isLiked = false;
    isLoading.value = false;
    // update();
  }

  void actionRemovePost(Post post, bool isMine) async {
    // var result = await Utils.dialog(
    //     'Instagram', 'Are you sure you want to remove this post?', false);
    if (isMine) {
      isLoading.value = true;
      FirestoreService.removePost(post).then((value) => {requestForFeed()});
    } else{
      isLoading.value = true;
      FirestoreService.removeFeed(post).then((value) => {requestForFeed()});
    }
  }

  void apiUnfollowUser(String uid) async {
    isLoading.value = true;
    // update();

    await FirestoreService.unfollowViaPost(uid).then((someone) {
      unfollowing(someone);
    });
  }

  void unfollowing(UserModel? someone) async {
    if (someone != null) {
      someone.isFollowed = false;
      isLoading.value = false;
      // update();
      await FirestoreService.removePostsFromMyFeed(someone);
      requestForFeed();
    } else {
      isLoading.value = false;
      // update();
    }
  }

  void bottomSheet(Post post) {
    Get.bottomSheet(
      SizedBox(
        height: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/icons/link.png'),
                  Image.asset('assets/icons/share.png'),
                  Image.asset('assets/icons/report.png'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                child: const Text('Hide',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onTap: () {
                  // posts.remove(post);
                  actionRemovePost(post, false);
                },
              ),
            ),
            const SizedBox(height: 20),
            post.uid != HiveService.getUID()
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      child: const Text('Unfollow',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      onTap: () {
                        apiUnfollowUser(post.uid!);
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      child: const Text('Delete',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      onTap: () {
                        actionRemovePost(post, true);
                      },
                    ),
                  ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          topLeft: Radius.circular(50),
        ),
      ),
      enableDrag: false,
    );
  }

  void shareFile(Post post) async {
    isLoading.value = true;
    // update();
    final box = Get.context!.findRenderObject() as RenderBox?;
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
    // update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    requestForFeed();
  }
}
