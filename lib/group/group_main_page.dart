import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_setting_page.dart';
import 'package:travelsync_client_new/group/notice_location_page.dart';
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/notice/notice_page.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

class GroupMainPage extends StatefulWidget {
  final int groupId;
  const GroupMainPage({super.key, required this.groupId});

  @override
  State<GroupMainPage> createState() => _GroupMainPageState();
}

class _GroupMainPageState extends State<GroupMainPage> {
  late bool isGuide = false;
  bool noticeExist = false;
  bool planExist = false;
  late GroupDetail groupdetail;
  List<Notice> noticeList = [];
  List<Plan> planList = [];
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  late String? url;

  checkUserState() async {
    userInfo = await storage.read(key: 'login');
    url = await storage.read(key: 'address');
    if (userInfo == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userInfo);
      await storage.write(key: 'groupId', value: widget.groupId.toString());
      await waitForGroupInfo();
    }
  }

  void goNoticePage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoticePage(
                  groupId: widget.groupId,
                )));
  }

  void viewTravlerLocation() {}
  void checkTraveler() {}
  void viewGuideLocation() {}

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
        if (groupdetail.guide == userInfo['accountName']) {
          isGuide = true;
        }
        await waitForNotice();
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

  waitForNotice() async {
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
        await waitForPlanList();
      } else {
        print('error');
      }
    } catch (e) {
      throw Error();
    }
  }

  waitForPlanList() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse('$url/plan/${groupdetail.tourId}'),
        headers: header,
      );
      if (response.statusCode == 200) {
        final plans = jsonDecode(utf8.decode(response.bodyBytes));
        for (var plan in plans) {
          planList.add(Plan.fromJson(plan));
          planExist = true;
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
            onPressed: () async {
              await storage.delete(key: 'groupId');
              navigatorKey.currentState?.pushNamed('/main');
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GroupSettingPage(groupId: widget.groupId)));
              },
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'settings',
              color: Colors.black,
              iconSize: 40,
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5FBFF),
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
                        // 나중에 지우기
                        textHeader: "Group Main",
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        groupdetail.tourCompany,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        groupdetail.groupName,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 12),
                          Text(
                            "${groupdetail.startDate} ~ ",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            groupdetail.endDate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, size: 12),
                          Text(
                            "가이드 ${groupdetail.guideName}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 20,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                "NOTICE",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              if (isGuide)
                                IconButton(
                                  onPressed: goNoticePage,
                                  icon: const Icon(Icons.search),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            width: 336,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 1,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                if (!noticeExist)
                                  const Text(
                                    "작성된 공지가 없습니다.\n새로운 공지를 등록해주세요!",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                // notice API 받아올시 Container 안에 넣어서 리스트 띄우기

                                if (noticeExist)
                                  SizedBox(
                                    width: 320,
                                    child: ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      itemCount: noticeList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        var notice = noticeList[index];
                                        return Container(
                                          width: 300,
                                          height: 62,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 238,
                                                  child: Row(
                                                    children: [
                                                      const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "위치",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            "시간",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
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
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            notice.noticeTitle,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            "${notice.parseHour()}:${notice.parseMinute()}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (notice.noticeLatitude !=
                                                        0 &&
                                                    notice.noticeLongitude != 0)
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  NoticeLocationPage(
                                                                      latitude:
                                                                          notice
                                                                              .noticeLatitude,
                                                                      longitude:
                                                                          notice
                                                                              .noticeLongitude)));
                                                    },
                                                    icon: const Icon(
                                                        Icons.location_on,
                                                        size: 36),
                                                  ),
                                              ],
                                            ),
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
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Text(
                                "TOUR",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            width: 336,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 1,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                // plan List 띄우는 부분
                                if (!planExist)
                                  const Text(
                                    "작성된 투어가 없습니다.\n그룹에서 새로운 투어를 가져와보세요!",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (planExist)
                                  SizedBox(
                                    width: 320,
                                    child: ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      itemCount: planList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        var plan = planList[index];
                                        return Container(
                                          width: 300,
                                          height: 62,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                          ),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            "시간",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 8),
                                                        child: Container(
                                                          width: 1,
                                                          height: 42,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "임시",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            "임시",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )),
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
                          ),
                        ],
                      ),
                      if (isGuide)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: viewTravlerLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "전체 위치 조회",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: checkTraveler,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "인원 점검",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!isGuide)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: viewGuideLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xfff5fbff),
                              ),
                              child: const Text(
                                "가이드 위치 조회",
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
