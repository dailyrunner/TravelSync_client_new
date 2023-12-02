import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/notice/notice_create.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:travelsync_client_new/widgets/notice_button.dart';

class NoticePage extends StatefulWidget {
  final int groupId;
  const NoticePage({super.key, required this.groupId});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  late bool noticeExist = false;
  late bool isGuide = false;
  List<Notice> noticeList = [];
  late String? url;
  late GroupDetail groupdetail;
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;

  checkUserState() async {
    userKey = await storage.read(key: 'login');
    url = await storage.read(key: 'address');
    if (userKey == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userKey);
      await waitForGroupInfo();
    }
  }

  waitForGroupInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
          Uri.parse("$url/group/detail/${widget.groupId}"),
          headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        groupdetail = GroupDetail.fromJson(responseBody);
        userInfo['accountName'] == groupdetail.guide
            ? isGuide = true
            : isGuide = false;
        await getNoticeList();
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text("페이지 로드 중 오류가 발생했습니다."),
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ));
    }
  }

  getNoticeList() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse('$url/notice/${widget.groupId}'),
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

  Future<void> wait() async {
    await checkUserState();
  }

  void createNotice() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoticeCreatePage(
                  groupId: widget.groupId,
                )));
  }

  void deleteNotice() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: wait(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Future Error!\n${snapshot.error}"),
                );
              }
              return SingleChildScrollView(
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
                        Column(
                          children: [
                            const Text(
                              "예정된 알림",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: noticeList.length,
                                itemBuilder: (context, index) {
                                  var notice = noticeList[index];

                                  return NoticeButton(
                                      notice: notice,
                                      onPressed: () {
                                        NoticeCreatePage(
                                            groupId: widget.groupId);
                                      },
                                      buttonColor: const Color(0xFFF5FBFF),
                                      width: 160.0);
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 5,
                                ),
                              ),
                            ),
                            const Text(
                              "이전 알림",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
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
                              onPressed: deleteNotice,
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
              );
            }),
      ),
    );
  }
}
