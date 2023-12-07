import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/notice/notice_create.dart';
import 'package:travelsync_client_new/notice/notice_edit.dart';
import 'package:travelsync_client_new/widgets/header.dart';

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

  late GroupDetail groupdetail;
  late String? url;
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
        final notices = jsonDecode(utf8.decode(response.bodyBytes));
        for (var notice in notices) {
          noticeList.add(Notice.fromJson(notice));
          noticeExist = true;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
              Future.microtask(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupMainPage(groupId: groupdetail.groupId),
                  ),
                );
              });
            },
          ),
        ),
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
                        height: 20,
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
                              "알림 목록",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 500,
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                itemCount: noticeList.length,
                                itemBuilder: (context, index) {
                                  var notice = noticeList[index];
                                  return TextButton(
                                    onPressed: () {
                                      Future.microtask(() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NoticeEditPage(
                                                    noticeId: notice.noticeId,
                                                    groupId: widget.groupId),
                                          ),
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 300,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Column(
                                                    children: [
                                                      Text(
                                                        "위치",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        "시간",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 8),
                                                    child: Container(
                                                      width: 1,
                                                      height: 42,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        notice.noticeTitle,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "${notice.parseHour()}:${notice.parseMinute()}",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 5,
                                ),
                              ),
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
