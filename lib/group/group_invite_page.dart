import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widget/home_page.dart';
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
  late Group groupInviteInfo;
  static const storage = FlutterSecureStorage();
  dynamic userInfo;

  final TextEditingController passwordController = TextEditingController();

  void acceptJoinGroup() async {
    if (passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("비밀번호를 입력해주세요."),
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
    try {
      Map<String, dynamic> data = {
        "groupId": widget.groupId,
        "groupPassword": passwordController.text
      };
      var body = json.encode(data);
      final response = await http.post(Uri.parse("$url/group/join"),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer ${userInfo["accessToken"]}",
            "Content-Type": "application/json"
          },
          body: body);
      if (response.statusCode == 200) {
        if (!mounted) return;
        var responseBody = jsonDecode(response.body);
        int groupId = responseBody["groupId"];
        Future.microtask(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupMainPage(groupId: groupId)));
        });

        return;
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("http 통신 오류"),
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
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("api오류"),
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
  }

  void declineJoinGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  checkUserState() async {
    try {
      userInfo = await storage.read(key: 'login');
      url = await storage.read(key: 'address');
      if (userInfo == null) {
        Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
      } else {
        userInfo = jsonDecode(userInfo);
        await waitForGroupInfo();
      }
    } catch (e) {
      print("에러");
    }
  }

  // 그룹에 소속된 사람이 아니면 group/detail/을 불러올 수 없어서 임시 주석처리
  waitForGroupInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
          Uri.parse("$url/group/inviteinfo/${widget.groupId}"),
          headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        groupInviteInfo = Group.fromJson(responseBody);
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text("그룹 정보를 받아오는 중 오류가 발생했습니다. groupinfo"),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Header(textHeader: "Invite"),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        // 임시
                        "가이드 ${groupInviteInfo.guide}님의 초대장이 도착했어요!",
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
                            "투어\n일정\n가이드",
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
                            // 임시
                            "${groupInviteInfo.groupName}\n${groupInviteInfo.startDate}~${groupInviteInfo.endDate}\n${groupInviteInfo.guide}",
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
                        // 임시
                        "${groupInviteInfo.groupName}에\n초대되셨습니다.\n\n초대를 수락 하시겠습니까?",
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
                                controller: passwordController,
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
