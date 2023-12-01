import 'package:flutter/material.dart';
import 'dart:convert'; // JSON Encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/tour/Tour.dart';
import 'package:travelsync_client_new/widget/settings_page.dart'; // flutter_secure_storage 패키지

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';

  checkUserState() async {
    userInfo = await storage.read(key: 'login');
    if (userInfo == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    }
  }

  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main/settings');
              },
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'settings',
              color: Colors.black,
              iconSize: 40,
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5FBFF),
        body: Column(
          children: [
            const airplaneLogo(),
            Container(
              height: 15,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Joined Group',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              height: 5,
            ),
            Container(
              height: 2.0, // 줄의 높이
              width: 250.0, // 줄의 가로 길이
              color: Colors.grey, // 줄의 색상
            ),
            Container(
              height: 15,
            ),
            SizedBox(
              height: 450,
              child: Column(
                children: [
                  Container(
                    height: 110,
                  ),
                  const Text(
                    '현재 가입되어 있는 그룹이 없습니다.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF003157),
                    ),
                  ),
                  const Text(
                    '초대 링크를 받아 그룹에 들어가거나',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF003157),
                    ),
                  ),
                  const Text(
                    '그룹을 직접 만들어보세요!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF003157),
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  Container(
                    width: 83,
                    height: 50,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/group_icon.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //투어 생성하기 버튼
            ElevatedButton(
              onPressed: () {
                // 버튼이 눌리면 다른 페이지로 이동
                Navigator.pushNamed(context, '/main/tour');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 45),
                backgroundColor: const Color(0xFFF5FBFF),
              ),
              child: const Text(
                '투어 생성하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              height: 10,
            ),
            //그룹 생성하기 버튼
            ElevatedButton(
              onPressed: () {
                // 버튼이 눌리면 다른 페이지로 이동
                Navigator.pushNamed(context, '/main/group');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 45),
                backgroundColor: const Color(0xFFF5FBFF),
              ),
              child: const Text(
                '그룹 생성하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
