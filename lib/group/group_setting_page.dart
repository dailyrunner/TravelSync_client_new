import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/group/tour_import_page.dart';
import 'package:travelsync_client_new/widget/globals.dart';
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
  late bool isGuide;
  late bool _isLocationShareEnabled;
  late String inviteCode;
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;
  late GroupDetail groupdetail;
  late String? url;
  Future? _groupInfoFuture;
  late int? _selectedTourId;

  importTour() async {
    _selectedTourId = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TourImportPage(
                  userId: userInfo["accountName"],
                )));
  }

  resetTour() async {
    _selectedTourId = null;
  }

  updateGroupSetting() async {
    try {
      Map<String, dynamic> data = {
        'groupId': widget.groupId,
        'guide': groupdetail.guide,
        'groupName': groupdetail.groupName,
        'startDate': groupdetail.startDate,
        'endDate': groupdetail.endDate,
        'nation': groupdetail.nation,
        'tourCompany': groupdetail.tourCompany,
        'toggleLoc': _isLocationShareEnabled,
        'tourId': _selectedTourId
      };
      var body = json.encode(data);
      final response = await http.put(Uri.parse("$url/group/setting"),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer ${userInfo["accessToken"]}",
            "Content-Type": "application/json"
          },
          body: body);
      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("설정 변경 완료"),
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
      Error();
    }
  }

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
          Uri.parse('$url/group/leave/${widget.groupId}'),
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
                  onPressed: () async {
                    await storage.delete(key: 'groupId');
                    Navigator.pop(context);
                    navigatorKey.currentState?.pushNamed('/main');
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
      final response = await http
          .delete(Uri.parse('$url/group/${widget.groupId}'), headers: header);
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
                  onPressed: () async {
                    await storage.delete(key: 'groupId');
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
    userInfo = await storage.read(key: 'login');
    url = await storage.read(key: 'address');
    if (userInfo == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userInfo);
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
        userInfo['accountName'] == groupdetail.guide
            ? isGuide = true
            : isGuide = false;
        _isLocationShareEnabled = groupdetail.toggleLoc;
        _selectedTourId = groupdetail.tourId;
        inviteCode =
            '${groupdetail.guide.substring(1, 4)}/${groupdetail.groupId}';
        inviteCode = base64Encode(utf8.encode(inviteCode));
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _groupInfoFuture = checkUserState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
          future: _groupInfoFuture,
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
            return Scaffold(
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
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Header(
                        textHeader: "Group Settings",
                      ),
                      if (isGuide)
                        Column(
                          children: [
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "투어 초기화",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: resetTour,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xfff5fbff),
                                  ),
                                  child: const Text(
                                    "TOUR 초기화",
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
                              "그룹 초대 코드",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(inviteCode),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () => Clipboard.setData(
                                ClipboardData(text: inviteCode),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "코드 복사",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: updateGroupSetting,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "설정 저장",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
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
                      if (!isGuide)
                        Column(
                          children: [
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
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
