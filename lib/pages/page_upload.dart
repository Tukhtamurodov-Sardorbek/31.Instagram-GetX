import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_upload.dart';
import 'package:instagramgetx/services/colors_service.dart';
import 'package:instagramgetx/widgets/appBar.dart';


class UploadPage extends StatefulWidget {
  static const String id = '/upload_page';
  PageController controller;
  UploadPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  @override
  Widget build(BuildContext context) {
    return GetX<UploadController>(
      init: UploadController(),
      builder: (_controller){
        return Scaffold(
            appBar: appBar(text: 'Upload', isCentered: true),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.82,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    // #pick image
                    GestureDetector(
                      child: Container(
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey.withOpacity(0.4),
                        child: _controller.selectedImage.isEmpty
                            ? const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                            size: 80,
                          ),
                        )
                            : Stack(
                          children: [
                            Image.file(
                              File(_controller.selectedImage.value),
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 4.0, 4.0, 0),
                                height: 26,
                                width: 26,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle
                                ),
                                child: IconButton(
                                  splashRadius: 1,
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                      Icons.cancel_outlined,
                                      color: ColorService.lightColor,
                                      size: 26
                                  ),
                                  onPressed: () {
                                    _controller.cancel();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      onTap: () {
                        _controller.selectedImage.isEmpty ? _controller.mediaSource(context) : () {};
                      },
                    ),
                    const SizedBox(height: 5),
                    _controller.selectedImageSize.isNotEmpty
                        ? Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                      child: Text('Size: ${_controller.selectedImageSize}',
                          style: TextStyle(
                              color: ColorService.lightColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    )
                        : const SizedBox(),
                    const SizedBox(height: 5),
                    // #comment
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextField(
                          controller: _controller.captionController.value,
                          focusNode: _controller.captionFocus.value,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                              label: const Text('Write a caption...'),
                              labelStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: ColorService.lightColor.withOpacity(0.7)
                              ),
                              border: InputBorder.none,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: ColorService.lightColor,
                                      width: 2
                                  )
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: ColorService.lightColor,
                                      width: 4
                                  )
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: MaterialButton(
                        height: 45,
                        minWidth: MediaQuery.of(context).size.width,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        color: ColorService.lightColor,
                        child: _controller.isLoading.value
                            ? const Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: Colors.white)),)
                            : const Text(
                            'Upload',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        onPressed: _controller.uploadPost,
                      ),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
