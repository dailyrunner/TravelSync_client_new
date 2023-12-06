import 'package:flutter/material.dart';
import 'package:travelsync_client_new/widget/login_page.dart';
import 'package:travelsync_client_new/widget/mainloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStart extends StatefulWidget {
  const AppStart({super.key});
  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const storage = FlutterSecureStorage();
  final String url = 'http://34.83.150.5';
  final int groupId = 19;

  saveURL() async {
    await storage.write(key: 'address', value: url);
    await storage.write(key: 'groupId', value: groupId.toString());
  }

  @override
  void initState() {
    super.initState();
    // 2초 후에 다음 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      saveURL();
    });
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
