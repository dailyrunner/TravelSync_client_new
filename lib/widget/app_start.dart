import 'package:flutter/material.dart';
import 'package:travelsync_client_new/group/group_invite_page.dart';
import 'package:travelsync_client_new/widget/login_page.dart';
import 'package:travelsync_client_new/widget/mainloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uni_links/uni_links.dart';

class AppStart extends StatefulWidget {
  const AppStart({super.key});
  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  String? _groupId;
  static const storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      // ignore: prefer_const_declarations, unnecessary_nullable_for_final_variable_declarations
      final String? initialLink =
          // await getInitialLink();
          "travelsync://invite/group/5";

      if (initialLink != null) {
        var uri = Uri.parse(initialLink);
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'group' &&
            int.tryParse(uri.pathSegments[1]) != null) {
          _groupId = uri.pathSegments[1];
        }
      }
    } on Exception {
      // 에러 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _groupId == null
          ? const SplashScreen()
          : GroupInvitePage(groupId: int.parse(_groupId!)),
    );
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

  saveURL() async {
    await storage.write(key: 'address', value: url);
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
