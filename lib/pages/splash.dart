import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:passpix/pages/home.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(splash: 
    LottieBuilder.asset("image_assets/passpix splash.json"),
    nextScreen: const HomePage(),
    splashIconSize: 200,
    );
  }
}


