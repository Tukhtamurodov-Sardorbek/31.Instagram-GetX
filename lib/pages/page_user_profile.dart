import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_user_profile.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/services/colors_service.dart';

class UserProfilePage extends StatefulWidget {
  String uid;
  UserProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {

  final controller = Get.put(UserController());
  
  @override
  void initState() {
    // TODO: implement initState
    controller.tabController =
        TabController(vsync: this, length: controller.tabs.length);

    controller.apiLoadUser(widget.uid);
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
    return GetX<UserController>(
      init: UserController(),
      builder: (_controller){
        return Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: (){
                  Get.back();
                },
              ),
              title: const Text('Profile',
                  style: TextStyle(fontSize: 30, fontFamily: 'instagramFont')),
              centerTitle: true,
            ),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // #statistics
                      Container(
                        height: 95,
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // #User's profile image
                            Container(
                              height: 95,
                              width: 95,
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorService.lightColor, width: 2),
                                  shape: BoxShape.circle),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: _controller.profileOwner.value.profileImageURL == null
                                    ? Image.asset(
                                  'assets/profile_pictures/user.png',
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                )
                                    : CachedNetworkImage(
                                  imageUrl: _controller.profileOwner.value.profileImageURL!,
                                  placeholder: (context, url) => Image.asset(
                                      'assets/profile_pictures/user.png'),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                          'assets/profile_pictures/user.png'),
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // #Posts number
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_controller.postsNumber.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 20)),
                                const Text('Posts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 16)),
                              ],
                            ),
                            // #Followers number
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_controller.profileOwner.value.followers.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 20)),
                                const Text('Followers',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 16)),
                              ],
                            ),
                            // #Followings number
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_controller.profileOwner.value.followings.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 20)),
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
                        padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 14.0),
                        child: RichText(
                          text: TextSpan(
                              text: _controller.profileOwner.value.username,
                              style: TextStyle(
                                  color:
                                  Theme.of(context).brightness == Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19),
                              children: [
                                TextSpan(
                                  text: '\n${_controller.profileOwner.value.email}',
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
                    ]
                  ),
                ),
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
                _controller.posts.length > 0
                    ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _controller.tabController.index + 1,
                        mainAxisSpacing: 2.0,
                        crossAxisSpacing: 2.0
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return _itemOfPost(_controller.posts[index]);
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
              // child: Container(
              //   width: MediaQuery.of(context).size.width,
              //   padding: const EdgeInsets.symmetric(vertical: 10.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       // #statistics
              //       Container(
              //         height: 95,
              //         padding: const EdgeInsets.symmetric(horizontal: 6.0),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             // #User's profile image
              //             Container(
              //               height: 95,
              //               width: 95,
              //               padding: const EdgeInsets.all(2.0),
              //               decoration: BoxDecoration(
              //                   border: Border.all(
              //                       color: ColorService.lightColor, width: 2),
              //                   shape: BoxShape.circle),
              //               child: ClipRRect(
              //                 borderRadius: BorderRadius.circular(50),
              //                 child: _controller.profileOwner.value.profileImageURL == null
              //                     ? Image.asset(
              //                   'assets/profile_pictures/user.png',
              //                   height: 90,
              //                   width: 90,
              //                   fit: BoxFit.cover,
              //                 )
              //                     : CachedNetworkImage(
              //                   imageUrl: _controller.profileOwner.value.profileImageURL!,
              //                   placeholder: (context, url) => Image.asset(
              //                       'assets/profile_pictures/user.png'),
              //                   errorWidget: (context, url, error) =>
              //                       Image.asset(
              //                           'assets/profile_pictures/user.png'),
              //                   height: 90,
              //                   width: 90,
              //                   fit: BoxFit.cover,
              //                 ),
              //               ),
              //             ),
              //             // #Posts number
              //             Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Text(_controller.postsNumber.toString(),
              //                     style: const TextStyle(
              //                         fontWeight: FontWeight.bold, fontSize: 20)),
              //                 const Text('Posts',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         color: Colors.grey,
              //                         fontSize: 16)),
              //               ],
              //             ),
              //             // #Followers number
              //             Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Text(_controller.profileOwner.value.followers.toString(),
              //                     style: const TextStyle(
              //                         fontWeight: FontWeight.bold, fontSize: 20)),
              //                 const Text('Followers',
              //                     style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         color: Colors.grey,
              //                         fontSize: 16)),
              //               ],
              //             ),
              //             // #Followings number
              //             Padding(
              //               padding: const EdgeInsets.only(right: 4.0),
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   Text(_controller.profileOwner.value.followings.toString(),
              //                       style: const TextStyle(
              //                           fontWeight: FontWeight.bold, fontSize: 20)),
              //                   const Text('Following',
              //                       style: TextStyle(
              //                           fontWeight: FontWeight.bold,
              //                           color: Colors.grey,
              //                           fontSize: 16)),
              //                 ],
              //               ),
              //             )
              //           ],
              //         ),
              //       ),
              //       // #bio
              //       Padding(
              //         padding: const EdgeInsets.fromLTRB(8.0, 14.0, 8.0, 14.0),
              //         child: RichText(
              //           text: TextSpan(
              //               text: _controller.profileOwner.value.username,
              //               style: TextStyle(
              //                   color:
              //                   Theme.of(context).brightness == Brightness.light
              //                       ? Colors.black
              //                       : Colors.white,
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: 19),
              //               children: [
              //                 TextSpan(
              //                   text: '\n${_controller.profileOwner.value.email}',
              //                   style: const TextStyle(
              //                       fontWeight: FontWeight.w600,
              //                       color: Colors.blueGrey,
              //                       fontSize: 16),
              //                 ),
              //               ]),
              //         ),
              //       ),
              //       // #buttons
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             MaterialButton(
              //               height: 34,
              //               minWidth: MediaQuery.of(context).size.width * 0.3,
              //               shape: const RoundedRectangleBorder(
              //                 side: BorderSide(color: Colors.grey),
              //               ),
              //               onPressed: () {},
              //               child: const Text(
              //                 'Edit profile',
              //                 textAlign: TextAlign.center,
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 15),
              //               ),
              //             ),
              //             MaterialButton(
              //               height: 34,
              //               minWidth: MediaQuery.of(context).size.width * 0.3,
              //               shape: const RoundedRectangleBorder(
              //                 side: BorderSide(color: Colors.grey),
              //               ),
              //               onPressed: () {},
              //               child: const Text(
              //                 'Ad tools',
              //                 textAlign: TextAlign.center,
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 15),
              //               ),
              //             ),
              //             MaterialButton(
              //               height: 34,
              //               minWidth: MediaQuery.of(context).size.width * 0.3,
              //               shape: const RoundedRectangleBorder(
              //                 side: BorderSide(color: Colors.grey),
              //               ),
              //               onPressed: () {},
              //               child: const Text(
              //                 'Insights',
              //                 textAlign: TextAlign.center,
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 15),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       // #gridselect
              //       SizedBox(
              //         height: 50,
              //         child: Row(
              //           children: [
              //             Expanded(
              //                 child: Center(
              //                     child: IconButton(
              //                       onPressed: () {
              //                         _controller.changeToList();
              //                       },
              //                       icon: const Icon(
              //                         Icons.grid_off,
              //                         size: 24,
              //                       ),
              //                     ))),
              //             Expanded(
              //                 child: Center(
              //                     child: IconButton(
              //                       onPressed: () {
              //                         _controller.changeToGrid();
              //                       },
              //                       icon: const Icon(
              //                         Icons.grid_view,
              //                         size: 24,
              //                       ),
              //                     ))),
              //           ],
              //         ),
              //       ),
              //       Expanded(
              //           child: GridView.builder(
              //               itemCount: _controller.posts.length,
              //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //                 crossAxisCount: _controller.axisCount.value,
              //               ),
              //               itemBuilder: (context, index) {
              //                 return _itemOfPost(_controller.posts[index]);
              //               }))
              //     ],
              //   ),
              // ),
            ));
      },
    );
  }

  Widget _itemOfPost(Post post) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.all(5),
          child: CachedNetworkImage(
            imageUrl: post.image,
            placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator.adaptive()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            height: controller.tabController.index == 0 ? 320 : controller.tabController.index == 1 ? 180 : 118,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        controller.tabController.index == 0 ?
        // #likeshare
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                splashRadius: 1,
                icon: Icon(
                    post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.isLiked
                        ? Colors.red
                        : Colors.black,
                    size: 30),
                onPressed: () {
                  if (!post.isLiked) {
                    controller.apiPostLike(post);
                  } else {
                    controller.apiPostUnlike(post);
                  }
                },
              ),
              GestureDetector(
                child: Image.asset(
                  'assets/icons/comment.png',
                  height: 28,
                  width: 28,
                ),
                onTap: () {},
              ),
              const SizedBox(width: 8.0),
              IconButton(
                splashRadius: 1,
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 16.0, 0.0),
                icon: const Icon(Icons.share,
                    color: Colors.black, size: 28),
                onPressed: () {
                  controller.shareFile(post, context);
                },
              ),
            ],
          ),
          trailing: GestureDetector(
            child: Image.asset(
              'assets/icons/save_outline.png',
              height: 28,
              width: 28,
            ),
            onTap: () {},
          ),
        ) : const SizedBox()
      ],
    );
  }
}
