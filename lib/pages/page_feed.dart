import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_feed.dart';
import 'package:instagramgetx/pages/page_user_profile.dart';
import 'package:instagramgetx/services/colors_service.dart';
import 'package:instagramgetx/widgets/appBar.dart';

class FeedPage extends StatefulWidget {
  static const String id = '/feed_page';
  PageController controller;
  FeedPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return GetX<FeedController>(
        init: FeedController(),
        builder: (_controller) {
          return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Column(
                  children: [
                    appBar(
                        text: 'Instagram',
                        isCentered: false,
                        leading: Icon(Icons.camera_alt, size: 28, color: ColorService.lightColor),
                        action: Image.asset('assets/icons/send.png', height: 26, width: 26, color: ColorService.lightColor),
                        onPressedLeading: () {
                          widget.controller.jumpToPage(2);
                        },
                        onPressedAction: () {},
                        isLoading: _controller.isLoading.value
                    ),
                    _controller.isLoading.value
                        ? LinearProgressIndicator(color: ColorService.lightColor, backgroundColor: ColorService.deepColor)
                        : const SizedBox(),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.posts.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(color: ColorService.lightColor, thickness: 2);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            ListTile(
                              contentPadding:
                              const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                              onTap: () {
                                if (!_controller.posts[index].isMine) {
                                  Get.to(() => UserProfilePage(uid: _controller.posts[index].uid!));
                                }
                              },
                              // tileColor: Colors.black45,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: _controller.posts[index].profileImage == null
                                    ? Image.asset(
                                  'assets/profile_pictures/user.png',
                                  height: 45,
                                  width: 45,
                                  fit: BoxFit.cover,
                                )
                                    : CachedNetworkImage(
                                  imageUrl: _controller.posts[index].profileImage!,
                                  placeholder: (context, url) => Image.asset('assets/profile_pictures/user.png'),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/profile_pictures/user.png'), height: 45, width: 45, fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                  _controller.posts[index].username ?? 'User',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                              ),
                              subtitle: Text(_controller.posts[index].date ?? ''),
                              trailing: IconButton(
                                splashRadius: 1,
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  _controller.bottomSheet(_controller.posts[index]);
                                },
                              ),
                            ),
                            // #image
                            GestureDetector(
                              child: CachedNetworkImage(
                                imageUrl: _controller.posts[index].image,
                                placeholder: (context, url) => const Center(
                                    child:
                                    CircularProgressIndicator.adaptive()),
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/icons/not_found.png'),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                              onDoubleTap: () {
                                if (!_controller.posts[index].isLiked) {
                                  _controller
                                      .apiPostLike(_controller.posts[index]);
                                } else {
                                  _controller
                                      .apiPostUnlike(_controller.posts[index]);
                                }
                              },
                            ),

                            // #likeshare
                            ListTile(
                              contentPadding:
                              const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    splashRadius: 1,
                                    icon: Icon(
                                        _controller.posts[index].isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _controller.posts[index].isLiked
                                            ? Colors.red
                                            : Colors.black,
                                        size: 30),
                                    onPressed: () {
                                      if (!_controller.posts[index].isLiked) {
                                        _controller.apiPostLike(
                                            _controller.posts[index]);
                                      } else {
                                        _controller.apiPostUnlike(
                                            _controller.posts[index]);
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
                                      _controller
                                          .shareFile(_controller.posts[index]);
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
                            ),

                            // #caption
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Text(
                                _controller.posts[index].caption,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              ));
        });
  }
}
