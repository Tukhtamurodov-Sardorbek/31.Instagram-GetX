import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramgetx/controls/controller_home.dart';
import 'package:instagramgetx/models/post_model.dart';
import 'package:instagramgetx/services/firestore_service.dart';
import 'package:instagramgetx/services/storage_service.dart';
import 'package:instagramgetx/services/utils_service.dart';

class UploadController extends GetxController{
  final captionController = TextEditingController().obs;
  final captionFocus = FocusNode().obs;
  var isLoading = false.obs;
  var selectedImage = ''.obs;
  var selectedImageSize = ''.obs;
  // File? _image;


  // #camera
  imageFromCamera() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    if(image != null){
      selectedImage.value = image.path;
      selectedImageSize.value =(File(selectedImage.toString()).lengthSync() / 1024 / 1024).toStringAsFixed(2) + ' Mb';
      // update();
    }
  }

  // #gallery
  imageFromGallery() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if(image != null){
      selectedImage.value = image.path;
      selectedImageSize.value = (File(selectedImage.toString()).lengthSync() / 1024 / 1024).toStringAsFixed(2) + ' Mb';
      // update();
    }
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

  // #upload button
  void uploadPost(){
    captionFocus.value.unfocus();
    String caption = captionController.value.text.toString().trim();
    if(selectedImage.isEmpty && caption.isEmpty){
      Utils.snackBar('Warning!', 'Attach a photo and make a caption, please!');
      return;
    }else if(selectedImage.isEmpty){
      Utils.snackBar('Warning!', 'Attach a photo, please!');
      return;
    } else if(caption.isEmpty){
      Utils.snackBar('Warning!', 'Leave a caption, please!');
      return;
    }
    postImage(caption);
  }

  void postImage(String caption) {
    isLoading.value = true;
    // update();

    StorageService.uploadPostImage(File(selectedImage.toString())).then((downloadUrl) => {resPostImage(caption, downloadUrl!)});
  }

  void resPostImage(String caption, String downloadUrl) {
    Post post = Post(caption: caption, image: downloadUrl);
    apiStorePost(post);
  }

  void apiStorePost(Post post) async {
    Post posted = await FirestoreService.storePost(post);
    FirestoreService.storeFeed(posted).then((value) => {moveToFeed()});
  }

  void moveToFeed() {
    isLoading.value = false;
    selectedImage.value = '';
    selectedImageSize.value = '';
    captionController.value.clear();
    // update();
    Get.find<HomeController>().pageController.value.jumpToPage(0);
  }

  void cancel(){
    selectedImage.value = '';
    selectedImageSize.value = '';
    // update();
  }

  @override
  void onClose() {
    captionController.value.dispose();
    captionFocus.value.dispose();
    super.onClose();
  }

}