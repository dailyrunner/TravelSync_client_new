import 'package:flutter/material.dart';
import 'package:travelsync_client_new/widget/login_page.dart';
import 'package:travelsync_client_new/widget/mainloading.dart';

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 후에 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StartingPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Mainloading();
  }
}
