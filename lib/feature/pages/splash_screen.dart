// ignore_for_file: unnecessary_null_comparison

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_chat/feature/pages/login_page.dart';
import 'package:firebase_chat/helper/helper_functions.dart';
import 'package:firebase_chat/shared/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isSignedIn = false;
  @override
  void initState(){
    super.initState();
    getUserLoggedInStatus();
  }

  void getUserLoggedInStatus()async{
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value!=null){
        setState((){
          _isSignedIn = value;
        });
      }
    });
    Future.delayed(const Duration(seconds: 3)).then((e) {
      if(_isSignedIn){
        pushReplaceRoute(context, const HomePage());
      }
      else{
        pushReplaceRoute(context, const LogInPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/splash.json',
                width: double.infinity,fit: BoxFit.fitWidth,animate: true),
            DefaultTextStyle(
              style:  TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('We Chat!'),
                ],
                isRepeatingAnimation: false,
                onTap: () {

                },
              ),
            ),
            const Text("Let's Chat Together")
          ],
        ),
      ),
    );
  }
}
