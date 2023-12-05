import 'package:flutter/material.dart';
import 'dart:convert'; // JSON Encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_invite_page.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/userinfo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart'; // flutter_secure_storage 패키지
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String url;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userKey = ''; // storage에 있는 유저 정보를 저장
  dynamic userInfo = '';
  UserInfo realUserInfo = UserInfo('로딩중.....', '로딩중...', '로딩중.......');
  TextEditingController inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userKey = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;

    // user의 정보가 없다면 로그인 페이지로 넘어가게 합니다.
    if (userKey == null) {
      navigatorKey.currentState?.pushNamed('/');
    } else {
      userInfo = jsonDecode(userKey);
      await getUserInfo();
    }
  }

  getUserInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      String userId = userInfo["accountName"];
      final response =
          await http.get(Uri.parse("$url/user/info/$userId"), headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        realUserInfo = UserInfo.fromJson(responseBody);
        setState(() {});
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text(" 오류가 발생했습니다."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("닫기"),
                      onPressed: () {
                        navigatorKey.currentState?.pop();
                      },
                    ),
                  ],
                );
              },
            ));
      }
    } catch (e) {
      if (!mounted) return;
      Future.microtask(() => showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("그룹페이지 api(그룹정보)오류"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () {
                      navigatorKey.currentState?.pop();
                    },
                  ),
                ],
              );
            },
          ));
    }
  }

  logout() async {
    await storage.delete(key: 'login');
    navigatorKey.currentState?.pushNamed('/');
  }

  checkInviteCode() async {
    if (inviteCodeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("초대 코드를 입력해주세요."),
            actions: <Widget>[
              TextButton(
                child: const Text("닫기"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }
    String decoded = utf8.decode(base64Decode(inviteCodeController.text));
    List<String> parts = decoded.split('/');
    int? groupId = int.tryParse(parts.last);
    if (groupId == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("잘못된 코드입니다."),
            actions: <Widget>[
              TextButton(
                child: const Text("닫기"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
    Future.microtask(
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupInvitePage(
            groupId: groupId!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
            ),
            tooltip: '뒤로가기',
            color: Colors.black,
            onPressed: () {
              navigatorKey.currentState?.pop();
            },
          ),
        ),
        body: Column(
          children: [
            const airplaneLogo(),
            Container(
              height: 10,
            ),
            const Header(textHeader: "Settings"),
            Container(
              height: 40,
            ),
            Row(
              children: [
                Container(
                  width: 40,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                  ),
                  width: 70,
                  child: const Text(
                    "내 정보",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 20,
            ),
            Container(
              //여기에 내정보 표시
              height: 100,
              width: 330,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                //이름, 이메일, 전화번호 모아놓음
                children: [
                  SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 5,
                            ),
                            const Text(
                              '이름',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 5,
                            ),
                            const Text(
                              '이메일',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 5,
                            ),
                            const Text(
                              '전화번호',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 85,
                    child: VerticalDivider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 190,
                        child: Column(
                          children: [
                            Container(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  realUserInfo.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  realUserInfo.userId,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  realUserInfo.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              navigatorKey.currentState
                                  ?.pushNamed('/main/settings/infoChange');
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/edit_icon.png'), // 이미지 경로
                                  fit: BoxFit.cover, // 이미지의 맞춤 방법 설정
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "클릭하세요",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
            ),
            // !
            const Text(
              '다른계정이 있으신가요?',
              style: TextStyle(
                color: Color.fromARGB(255, 11, 73, 121),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              height: 3,
            ),
            GestureDetector(
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: InkWell(
                    onTap: () {
                      logout(); // 로그아웃
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                        bottom: 5,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      width: 90,
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 10,
            ),
            GestureDetector(
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: InkWell(
                    onTap: () {
                      logout(); // 로그아웃
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                        bottom: 5,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      width: 90,
                      child: const Text(
                        '회원탈퇴',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                bottom: 5,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
              ),
              width: 90,
              child: const Text(
                '그룹 가입',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: inviteCodeController,
                decoration: const InputDecoration(
                  hintText: '초대 코드 입력',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: checkInviteCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF5FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor:
                      const Color.fromARGB(255, 80, 80, 80).withOpacity(0.7),
                  elevation: 2.0,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 16,
                  ),
                  child: Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
