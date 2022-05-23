import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_home.dart';
import 'package:instagramgetx/pages/page_feed.dart';
import 'package:instagramgetx/pages/page_likes.dart';
import 'package:instagramgetx/pages/page_profile.dart';
import 'package:instagramgetx/pages/page_search.dart';
import 'package:instagramgetx/pages/page_upload.dart';
import 'package:instagramgetx/services/colors_service.dart';

import '../controls/controller_profile.dart';

class HomePage extends StatefulWidget {
  static const String id = '/home_page';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final controller = Get.put(HomeController());
  final _controller = Get.put(ProfileController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.initNotification(context);
    _controller.getUserFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      init: HomeController(),
      builder: (_controller){
        return Scaffold(
          body: WillPopScope(
            onWillPop: () async{
              final now = DateTime.now();
              const maxDuration = Duration(seconds: 2);
              final isWarning = now.difference(_controller.lastPressed.value) > maxDuration;

              if(isWarning){
                _controller.updateLastTime();
                // doubleTap(context);
                return false;
              } else{
                return true;
              }
            },
            child: PageView(
              controller: _controller.pageController.value,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                FeedPage(controller: _controller.pageController.value),
                const SearchPage(),
                UploadPage(controller: _controller.pageController.value),
                const LikesPage(),
                const ProfilePage()
              ],
              onPageChanged: (int index) {
                _controller.changePage(index);
              },
            ),
          ),
          bottomNavigationBar: CupertinoTabBar(
            currentIndex: _controller.currentPage.value,
            activeColor: ColorService.lightColor,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home)),
              BottomNavigationBarItem(icon: Icon(Icons.search)),
              BottomNavigationBarItem(icon: Icon(Icons.add_box)),
              BottomNavigationBarItem(icon: Icon(Icons.favorite)),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
            ],
            onTap: (int index) {
              _controller.pageController.value.jumpToPage(index);
            },
          ),
        );
      },
    );
  }
}
