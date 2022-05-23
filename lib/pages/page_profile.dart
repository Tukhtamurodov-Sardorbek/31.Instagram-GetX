import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_profile.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/services/colors_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final controller = Get.put(ProfileController());

  @override
  void initState() {
    controller.getUserFromFirestore();
    controller.getPosts();
    controller.tabController =
        TabController(vsync: this, length: controller.tabs.length);
    controller.tabController.addListener(() {
      if (controller.tabController.indexIsChanging) {
        controller.posts.refresh();
        controller.update();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<ProfileController>(
      init: ProfileController(),
      builder: (_controller) {
        return Scaffold(
          appBar: AppBar(
              title: Text(
                _controller.profileOwner.value.username.toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              actions: [
                IconButton(
                  splashRadius: 1,
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _controller.logOut,
                ),
              ],
              elevation: 0.0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: _controller.isLoading.value
                    ? LinearProgressIndicator(
                        color: ColorService.lightColor,
                        backgroundColor: ColorService.deepColor)
                    : const SizedBox(),
              )),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // #statistics
                      Container(
                        height: 95,
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              child: Container(
                                height: 95,
                                width: 95,
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorService.lightColor,
                                        width: 2),
                                    shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: _controller.profileOwner.value
                                              .profileImageURL ==
                                          null
                                      ? Image.asset(
                                          'assets/profile_pictures/user.png',
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: _controller.profileOwner.value.profileImageURL!,
                                          placeholder: (context, url) => Image.asset('assets/profile_pictures/user.png'),
                                          errorWidget: (context, url, error) => Image.asset('assets/profile_pictures/user.png'),
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              onLongPress: () {
                                _controller.mediaSource(context);
                              },
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_controller.postsNumber.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const Text('Posts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 16)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    _controller.profileOwner.value.followers
                                        .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const Text('Followers',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 16)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      _controller.profileOwner.value.followings
                                          .toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  const Text('Following',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 16)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      // #bio
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 14.0),
                        child: RichText(
                          text: TextSpan(
                              text: _controller.profileOwner.value.username,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19),
                              children: [
                                TextSpan(
                                  text:
                                      '\n${_controller.profileOwner.value.email}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey,
                                      fontSize: 16),
                                ),
                              ]),
                        ),
                      ),
                      // #buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              height: 34,
                              minWidth: MediaQuery.of(context).size.width * 0.3,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Edit profile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            MaterialButton(
                              height: 34,
                              minWidth: MediaQuery.of(context).size.width * 0.3,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Ad tools',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            MaterialButton(
                              height: 34,
                              minWidth: MediaQuery.of(context).size.width * 0.3,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Insights',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                childCount: 1,
              )),
              SliverAppBar(
                pinned: true,
                snap: false,
                floating: false,
                expandedHeight: 0,
                toolbarHeight: 20,
                bottom: TabBar(
                    controller: _controller.tabController,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black,
                    tabs: _controller.tabs),
              ),
              _controller.posts.isNotEmpty
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _controller.tabController.index == 0
                              ? 1
                              : _controller.tabController.index == 1
                                  ? 2
                                  : 3,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return myPost(_controller.posts[index]);
                        },
                        childCount: _controller.posts.length,
                      ))
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return SizedBox(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Image.asset(
                                'assets/icons/not_found.png',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        childCount: 1,
                      ))
            ],
          ),
        );
      },
    );
  }

  Widget myPost(Post post) {
    return GestureDetector(
      onLongPress: () {
        controller.actionRemovePost(post);
      },
      child: Card(
        elevation: 20.0,
        color: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: CachedNetworkImage(
            imageUrl: post.image,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            errorWidget: (context, url, error) =>
                Image.asset('assets/icons/not_found.png'),
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
