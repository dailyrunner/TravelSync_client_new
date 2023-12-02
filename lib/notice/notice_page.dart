import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/notice/notice_create.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class NoticePage extends StatefulWidget {
  final int groupId;
  const NoticePage({super.key, required this.groupId});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  late bool noticeExist = false;
  late bool isGuide = true;
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;
  List<Notice> noticeList = [];

  checkUserState() async {
    userKey = await storage.read(key: 'login');
    if (userKey == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userKey);
      await getNoticeList();
    }
  }

  getNoticeList() async {
    try {
      final url = 'http://34.83.150.5:8080/notice/${widget.groupId}';
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse(url),
        headers: header,
      );
      if (response.statusCode == 200) {
        final notices = jsonDecode(response.body);
        if (notices == null) {
          noticeExist = false;
          return;
        }
        for (var notice in notices) {
          noticeList.add(Notice.fromJson(notice));
        }
      } else {
        print('error');
      }
    } catch (e) {
      throw Error();
    }
  }

  void createNotice() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NoticeCreatePage()));
  }

  void deleteNotice() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Header(
                  textHeader: "Notice",
                ),
                const SizedBox(
                  height: 60,
                ),
                if (!noticeExist)
                  Column(
                    children: [
                      Container(
                        child: const SingleChildScrollView(
                          child: Text(
                            "그룹에 등록된 알림이 없습니다.",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 504,
                      ),
                    ],
                  ),
                if (noticeExist)
                  const Column(
                    children: [
                      Text(
                        "예정된 알림",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: SingleChildScrollView(),
                      ),
                      Text(
                        "이전 알림",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 320,
                        child: SingleChildScrollView(),
                      ),
                    ],
                  ),
                if (isGuide)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: createNotice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "NOTICE 만들기",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: createNotice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "NOTICE 삭제",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
