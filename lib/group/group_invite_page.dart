import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

class GroupInvitePage extends StatefulWidget {
  final int groupId;
  const GroupInvitePage({super.key, required this.groupId});

  @override
  State<GroupInvitePage> createState() => _GroupInvitePageState();
}

class _GroupInvitePageState extends State<GroupInvitePage> {
  late String? url;
  late GroupDetail groupdetail;
  late GuideInfo guideInfo;
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;

  final TextEditingController groupNameController = TextEditingController();

  void acceptJoinGroup() {}
  void declineJoinGroup() {}

  checkUserState() async {
    userKey = await storage.read(key: 'login');
    if (userKey == null) {
      print("userKey없음");
    }
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
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        groupdetail = GroupDetail.fromJson(responseBody);
        await waitForGuideInfo();
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text("그룹 정보를 받아오는 중 오류가 발생했습니다."),
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

  waitForGuideInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo['accessToken']}"
      };
      final response = await http.get(
          Uri.parse('$url/user/info/${groupdetail.guide}'),
          headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        guideInfo = GuideInfo.fromJson(responseBody);
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text("그룹 정보를 받아오는 중 오류가 발생했습니다."),
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
                content: const Text("그룹페이지 api(가이드) 오류"),
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

  Future<void> wait() async {
    await checkUserState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: wait(),
            builder: (context, snapshot) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Header(textHeader: "Invite"),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        "가이드 ${guideInfo.name}님의 초대장이 도착했어요!",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      const Icon(
                        Icons.mail_outline,
                        size: 48,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "투어 이름\n일정\n가이드",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            width: 10,
                            height: 60,
                            child: Container(
                              width: 1,
                              height: 56,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            "${groupdetail.groupName}\n${groupdetail.startDate}~${groupdetail.endDate}\n${guideInfo.name}",
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        "${groupdetail.groupName}에\n초대되셨습니다.\n\n초대를 수락 하시겠습니까?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                        width: 480,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Flexible(
                              flex: 3,
                              child: Text(
                                "그룹 비밀번호",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Flexible(
                              flex: 1,
                              child: SizedBox(width: 50),
                            ),
                            Flexible(
                              flex: 3,
                              child: TextField(
                                controller: groupNameController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: 360,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: acceptJoinGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "가입",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 120,
                            ),
                            ElevatedButton(
                              onPressed: declineJoinGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "거절",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
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
