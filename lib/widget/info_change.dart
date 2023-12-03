import 'package:flutter/material.dart';
import 'dart:convert'; // JSON Encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/userinfo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart'; // flutter_secure_storage 패키지
import 'package:http/http.dart' as http;

class InfoChange extends StatefulWidget {
  const InfoChange({Key? key}) : super(key: key);

  @override
  State<InfoChange> createState() => _InfoChangeState();
}

class _InfoChangeState extends State<InfoChange> {
  late String url;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userKey = ''; // storage에 있는 유저 정보를 저장
  dynamic userInfo = '';
  UserInfo realUserInfo = UserInfo('이메일', '이름', '전화번호');

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
                  width: 100,
                  child: const Text(
                    "내 정보 수정",
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
            //여기 이름. 휴대폰 번호 넣을건데 회원가입이랑 똑같은 형식으로
            Container(
              height: 100,
            ),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  //수정완료 제출하는 함수 호출
                  Navigator.pushNamed(context, '/main/settings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5FbFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor:
                      const Color.fromARGB(255, 80, 80, 80).withOpacity(0.7),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 16,
                  ),
                  child: Text(
                    '수정 완료',
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
