import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:news_app/Screen/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'assets/animation/Animation - 1733118533419.json',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 1),
            const Text(
              'News Now',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      nextScreen: const NewsHomeScreen(),
      splashIconSize: 500,
      duration: 4000,
      backgroundColor: Colors.greenAccent,
    );
  }
}
