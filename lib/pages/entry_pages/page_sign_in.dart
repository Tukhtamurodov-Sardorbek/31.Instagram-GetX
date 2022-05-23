import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagramgetx/controls/entry_pages/controller_sign_in.dart';
import 'package:instagramgetx/services/colors_service.dart';
import 'package:instagramgetx/widgets/entry_page/footers.dart';

class SignInPage extends StatefulWidget {
  static const String id = '/sign_in_page';
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  @override
  Widget build(BuildContext context) {
    return GetX<SignInController>(
      init: SignInController(),
      builder: (_controller){
        return Scaffold(
          body: WillPopScope(
            onWillPop: () async{
              final now = DateTime.now();
              const maxDuration = Duration(seconds: 2);
              final isWarning = _controller.lastPressed.value == null || now.difference(_controller.lastPressed.value) > maxDuration;

              if(isWarning){
                _controller.updateLastPressedTime();
                // doubleTap(context);
                return false;
              } else{
                return true;
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorService.lightColor,
                        ColorService.deepColor,
                      ]
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // #Instagram
                          const Center(
                              child: Text('Instagram', style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: 'instagramFont'))
                          ),
                          const SizedBox(height: 20),
                          // #Email
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: Colors.transparent,
                              elevation: 30,
                              child: TextField(
                                controller: _controller.emailController,
                                focusNode: _controller.emailFocus,
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                    filled: true,
                                    fillColor: Colors.white54.withOpacity(0.2),
                                    hintText: 'Email',
                                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 17, fontWeight: FontWeight.w500),
                                    prefixIcon: const Icon(Icons.mail, color: Colors.white54),
                                    suffixIcon: _controller.clearEmail.value ? IconButton(
                                        splashRadius: 1,
                                        icon: const Icon(CupertinoIcons.clear, size: 18, color: Colors.white54),
                                        onPressed: (){
                                          _controller.clear();
                                        }
                                    ) : const SizedBox(),

                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.transparent)
                                    ),
                                    enabledBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.transparent)
                                    ),
                                    focusedBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.transparent)
                                    )
                                ),
                                onChanged: (email) {
                                  _controller.onChangedFunction();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // #Password
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: Colors.transparent,
                              elevation: 30,
                              child: TextField(
                                controller: _controller.passwordController,
                                focusNode: _controller.passwordFocus,
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                obscureText: _controller.isHidden.value,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                    filled: true,
                                    fillColor: Colors.white54.withOpacity(0.2),
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 17, fontWeight: FontWeight.w500),
                                    prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                                    suffixIcon: IconButton(
                                      splashRadius: 1,
                                      icon:  Icon(
                                          _controller.isHidden.value
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined
                                      ),
                                      color: Colors.white54,
                                      onPressed: (){
                                        _controller.visibility();
                                      },
                                    ),


                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.transparent)
                                    ),
                                    enabledBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.transparent)
                                    ),
                                    focusedBorder:  OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.transparent)
                                    )
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // #Sign in button
                          MaterialButton(
                            color: ColorService.entryButtonColor,
                            minWidth: MediaQuery.of(context).size.width,
                            height: 40,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(color: Colors.white54)
                            ),
                            elevation: 20,
                            child: _controller.isLoading.value
                                ? const Center(child: SizedBox(height: 26, width: 26, child: CircularProgressIndicator(color: Colors.white)),)
                                : const Text('Sign In', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 18)),
                            onPressed: (){
                              _controller.signIn();
                            },
                          )
                        ],
                      )
                  ),
                  // #Sign Up
                  SignUpFooter(context)
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
