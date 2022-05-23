import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/controller_search.dart';
import 'package:instagramgetx/models/user_model.dart';
import 'package:instagramgetx/pages/page_user_profile.dart';
import 'package:instagramgetx/services/colors_service.dart';
import 'package:instagramgetx/widgets/appBar.dart';

class SearchPage extends StatefulWidget {
  static const String id = '/search_page';
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return GetX<SearchController>(
      init: SearchController(),
      builder: (_controller){
        return SafeArea(
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Column(
                    children: [
                      appBar(text: 'Search', isCentered: true),
                      TextField(
                        controller: _controller.searchController.value,
                        style: const TextStyle(color: Colors.black87, fontSize: 18),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        cursorColor: ColorService.lightColor,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white54,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 0.0),
                          hintText: 'Search',
                          hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 20),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffix: _controller.clearSearch.value
                              ? GestureDetector(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(CupertinoIcons.clear,
                                  color: ColorService.lightColor, size: 20),
                            ),
                            onTap: () {
                              _controller.tapped();
                            },
                          )
                              : const SizedBox(),
                          border: OutlineInputBorder(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                                color: ColorService.lightColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                                color: ColorService.lightColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: ColorService.lightColor),
                          ),
                        ),
                        onChanged: (search) {
                          _controller.changed(search);
                        },
                        onSubmitted: (search) {
                          _controller.searchFocus.value.unfocus();
                        },
                      ),
                      const SizedBox(height: 4.0),
                      _controller.isPressed.value
                          ? LinearProgressIndicator(
                          color: ColorService.lightColor,
                          backgroundColor: ColorService.deepColor) : const SizedBox()
                    ],
                  ),
                ),
              ),
              body: _controller.users.isEmpty && _controller.searchController.value.text.isNotEmpty
                  ? SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/user.png',
                        height: 140,
                        width: 140,
                        fit: BoxFit.cover,
                        color: ColorService.deepColor),
                    const SizedBox(height: 20),
                    Text(
                      'User not found',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorService.deepColor),
                    )
                  ],
                ),
              )
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.users.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 2.0);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return userWidget(_controller.users[index]);
                      },
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  ListTile userWidget(UserModel user) {
    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        onTap: () {
          Get.to(() => UserProfilePage(uid: user.uid!));
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: user.profileImageURL == null
              ? Image.asset(
            'assets/profile_pictures/user.png',
            height: 45,
            width: 45,
            fit: BoxFit.cover,
          )
              : CachedNetworkImage(
            imageUrl: user.profileImageURL!,
            placeholder: (context, url) =>
                Image.asset('assets/profile_pictures/user.png'),
            errorWidget: (context, url, error) =>
                Image.asset('assets/profile_pictures/user.png'),
            height: 45,
            width: 45,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(user.email,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1),
        trailing: MaterialButton(
          minWidth: 90,
          elevation: 3.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                  color:
                  user.isFollowed ? Colors.white : ColorService.lightColor,
                  width: 2)),
          color: user.isFollowed ? ColorService.lightColor : Colors.white,
          child: user.isFollowed
              ? const Text('Unfollow',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white))
              : Text('Follow',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: ColorService.lightColor)),
          onPressed: () {
            Get.find<SearchController>().pressed(user);
          },
        ));
  }
}
