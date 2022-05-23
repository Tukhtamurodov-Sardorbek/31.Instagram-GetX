import 'package:get/get.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/utils_service.dart';

class LikesController extends GetxController{
  var isLoading = false.obs;
  var posts = <Post>[].obs;


  void apiLoadLikes() {
    isLoading.value = true;
    // update();
    FirestoreService.loadLikes().then((value) => {resLoadLikes(value)});
  }

  void resLoadLikes(List<Post> _posts) {
    posts.value = _posts;
    isLoading.value = false;
    // update();
  }

  void actionRemovePost(Post post) async {
    var result = await Utils.dialog('Instagram', 'Are you sure you want to remove this post?', false);
    if (result) {
      isLoading.value = true;
      // update();

      await FirestoreService.likePost(post, false);
      await FirestoreService.removePost(post)
          .then((value) => {apiLoadLikes()});
    }
  }

  @override
  void onInit() {
    apiLoadLikes();
    super.onInit();
  }
}