import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_likes.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/pages/page_user_profile.dart';
import 'package:instagramgetx/widgets/appBar.dart';

class LikesPage extends StatefulWidget {
  static const String id = '/likes_page';
  const LikesPage({Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  @override
  Widget build(BuildContext context) {
    return GetX<LikesController>(
      init: LikesController(),
      builder: (_controller) {
        return Scaffold(
            appBar: appBar(text: 'Likes', isCentered: true),
            body: Stack(
              children: [
                _controller.posts.isNotEmpty
                    ? ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _controller.posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return likesWidget(_controller.posts[index]);
                        },
                      )
                    : const Center(
                        child: Text('No liked posts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 18)),
                      ),
                _controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : const SizedBox.shrink()
              ],
            ));
      },
    );
  }

  Widget likesWidget(Post post) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      onTap: () {
        if (!post.isMine) {
          Get.to(() => UserProfilePage(uid: post.uid!));
        }
      },
      onLongPress: () {
        Get.find<LikesController>().actionRemovePost(post);
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: post.profileImage == null
            ? Image.asset(
                'assets/profile_pictures/user.png',
                height: 45,
                width: 45,
                fit: BoxFit.cover,
              )
            : CachedNetworkImage(
                imageUrl: post.profileImage!,
                placeholder: (context, url) =>
                    Image.asset('assets/profile_pictures/user.png'),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/profile_pictures/user.png'),
                height: 45,
                width: 45,
                fit: BoxFit.cover,
              ),
      ),
      title: Text(post.username ?? 'User',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(post.caption,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1),
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: post.image,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator.adaptive()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          height: 70,
          width: 70,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
