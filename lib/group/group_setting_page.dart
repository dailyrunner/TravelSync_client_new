import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/widget/home_page.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

import '../models/group.dart';

class GroupSettingPage extends StatefulWidget {
  final int groupId;
  const GroupSettingPage({super.key, required this.groupId});

  @override
  State<GroupSettingPage> createState() => _GroupSettingPageState();
}

class _GroupSettingPageState extends State<GroupSettingPage> {
  late bool isGuide = true;
  bool _isLocationShareEnabled = false;
  late int groupPassword = 3355;
  late String groupURL = "travelsync.com/chohs";
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;
  late GroupDetail groupdetail;

  void importTour() {}

  leaveGroupAlert() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("정말로 이 그룹에서 나갈까요?"),
            actions: <Widget>[
              TextButton(
                child: Text("네",
                    style: TextStyle(
                      color: Colors.grey[400],
                    )),
                onPressed: () {
                  Navigator.pop(context);
                  leaveGroup();
                },
              ),
              TextButton(
                child: const Text("아니오",
                    style: TextStyle(
                      color: Colors.red,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  leaveGroup() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo['accessToken']}"
      };
      final response = await http.delete(
          Uri.parse('http://34.83.150.5:8080/group/leave/${widget.groupId}'),
          headers: header);
      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("그룹 탈퇴 완료"),
              actions: <Widget>[
                TextButton(
                  child: const Text("닫기"),
                  onPressed: () {
                    Navigator.pop(context);
                    Future.microtask(() => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage())));
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("그룹 탈퇴 실패"),
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

  deleteGroupAlert() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("정말로 이 그룹을 삭제할까요?"),
            actions: <Widget>[
              TextButton(
                child: Text("네",
                    style: TextStyle(
                      color: Colors.grey[400],
                    )),
                onPressed: () {
                  Navigator.pop(context);
                  deleteGroup();
                },
              ),
              TextButton(
                child: const Text("아니오",
                    style: TextStyle(
                      color: Colors.red,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  deleteGroup() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo['accessToken']}"
      };
      final response = await http.delete(
          Uri.parse('http://34.83.150.5:8080/group/${widget.groupId}'),
          headers: header);
      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("그룹 삭제 완료"),
              actions: <Widget>[
                TextButton(
                  child: const Text("닫기"),
                  onPressed: () {
                    Navigator.pop(context);
                    Future.microtask(() => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage())));
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("그룹 삭제 실패"),
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

  checkUserState() async {
    userKey = await storage.read(key: 'login');
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
          Uri.parse("http://34.83.150.5:8080/group/detail/${widget.groupId}"),
          headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        groupdetail = GroupDetail.fromJson(responseBody);
        userInfo['accountName'] == groupdetail.guide
            ? isGuide = true
            : isGuide = false;
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text("그룹 생성 중 오류가 발생했습니다."),
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

  @override
  void initState() {
    super.initState();
    checkUserState();
  }

  @override
  Widget build(BuildContext context) {
    if (isGuide) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Header(
                    textHeader: "Group Settings",
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "위치 공유 기능",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _isLocationShareEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isLocationShareEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "저장된 투어 불러오기",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: importTour,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfff5fbff),
                        ),
                        child: const Text(
                          "TOUR 불러오기",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "그룹 공유 링크",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text("비밀번호:$groupPassword\n$groupURL"),
                  ElevatedButton(
                    onPressed: deleteGroupAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff5fbff),
                    ),
                    child: const Text(
                      "그룹 삭제",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Header(
                    textHeader: "Group Settings",
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextButton(
                    onPressed: leaveGroupAlert,
                    child: const Text("그룹 나가기",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
