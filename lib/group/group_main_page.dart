import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_plan_page.dart';
import 'package:travelsync_client_new/group/group_setting_page.dart';
import 'package:travelsync_client_new/group/notice_location_page.dart';
import 'package:travelsync_client_new/location/people_check.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/models/tour.dart';
import 'package:travelsync_client_new/notice/notice_page.dart';
import 'package:travelsync_client_new/location/all_location.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/location/guide_location.dart';
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
  late Notice upcomingNotice;
  List<Plan> planList = [];
  List<Plan> todayPlan = [];
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  late String? url;
  late int travelday;
  Tour? selectedTour;

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

  void viewTravelerLocation() {
    if (!groupdetail.toggleLoc) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("현재 위치 공유 기능이 꺼져있습니다."),
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AllLocation()));
    }
  }

  void checkTraveler() {
    if (!groupdetail.toggleLoc) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("현재 위치 공유 기능이 꺼져있습니다."),
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PeopleCheck()));
    }
  }

  void viewGuideLocation() {
    if (!groupdetail.toggleLoc) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("현재 위치 공유 기능이 꺼져있습니다."),
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const GuideLocation()));
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
        if (groupdetail.guide == userInfo['accountName']) {
          isGuide = true;
        }
        List<dynamic> dayparts = groupdetail.startDate.split('-');
        DateTime today = DateTime.now();
        travelday = DateTime(today.year, today.month, today.day)
                .difference(DateTime(int.parse(dayparts[0]),
                    int.parse(dayparts[1]), int.parse(dayparts[2])))
                .inDays +
            1;
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
        for (dynamic notice in notices) {
          notice = Notice.fromJson(notice);
          if (DateTime.parse(notice.noticeDate).isBefore(DateTime.now())) {
            continue;
          }
          upcomingNotice = notice;
          noticeExist = true;
          break;
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
        if (planList.length > 1) {
          sortPlans(planList);
        }
        if (travelday <= 1) {
          for (Plan plan in planList) {
            if (plan.day != 1) break;
            todayPlan.add(plan);
          }
        } else {
          for (Plan plan in planList) {
            if (plan.day < travelday) {
              continue;
            }
            if (plan.day == travelday) {
              todayPlan.add(plan);
            } else {
              break;
            }
          }
        }
        await waitForTour();
      } else {
        print('error');
      }
    } catch (e) {
      throw Error();
    }
  }

  waitForTour() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse('$url/tour/${groupdetail.groupId}'),
        headers: header,
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(utf8.decode(response.bodyBytes));
        selectedTour = Tour.fromJson(responsebody);
      } else {
        print('error');
      }
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  void sortPlans(List<Plan> plans) {
    //day, time을 기준으로 오름차순 정렬
    plans.sort((a, b) {
      // day비교
      int dayComparison = a.day.compareTo(b.day);
      if (dayComparison != 0) {
        return dayComparison;
      }
      // day가 같을 때 time비교
      return a.time.compareTo(b.time);
    });
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
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
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
              iconSize: 45,
            ),
          ],
        ),
        backgroundColor: Colors.white,
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
                  padding:
                      const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Column(
                    children: [
                      const airplaneLogo(),
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
                      Header(
                          // 나중에 지우기
                          textHeader: groupdetail.groupName),
                      const SizedBox(
                        height: 20,
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
                                  color: Color(0xff002357),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              if (isGuide)
                                IconButton(
                                  onPressed: goNoticePage,
                                  icon: const Icon(Icons.edit),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 62,
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
                                if (noticeExist)
                                  Container(
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
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "위치",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "시간",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    upcomingNotice.noticeTitle,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${upcomingNotice.parseHour()}:${upcomingNotice.parseMinute()}",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NoticeLocationPage(
                                                              latitude:
                                                                  upcomingNotice
                                                                      .noticeLatitude,
                                                              longitude:
                                                                  upcomingNotice
                                                                      .noticeLongitude)));
                                            },
                                            icon: const Icon(Icons.location_on,
                                                size: 36),
                                          ),
                                        ],
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
                          Row(
                            children: [
                              const Text(
                                "TOUR",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff002357),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                onPressed: goGroupPlanPage,
                                icon: const Icon(Icons.search),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 226,
                            width: 336,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 216,
                                  width: 1,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                // plan List 띄우는 부분
                                if (todayPlan.isEmpty)
                                  const Text(
                                    "오늘 예정된 일정이 없습니다.\n그룹에 새로운 여행 계획을 가져와보세요!",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (planExist)
                                  SizedBox(
                                    width: 320,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Day $travelday",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff002357),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: 300,
                                            height: 180,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: ListView.separated(
                                                scrollDirection: Axis.vertical,
                                                itemCount: todayPlan.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  var plan = todayPlan[index];
                                                  return Row(
                                                    children: [
                                                      Text(
                                                        plan.time,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Text(
                                                        plan.planTitle,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const SizedBox(
                                                  height: 5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
                              onPressed: viewTravelerLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEFF5FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor:
                                    const Color.fromARGB(255, 80, 80, 80)
                                        .withOpacity(0.7),
                                elevation: 2.0,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "전체 위치 조회",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: checkTraveler,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEFF5FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor:
                                    const Color.fromARGB(255, 80, 80, 80)
                                        .withOpacity(0.7),
                                elevation: 2.0,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 26, //전체위치조회 button과 가로 길이 맞춤
                                ),
                                child: Text(
                                  "인원 점검",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
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
                                backgroundColor: const Color(0xFFEFF5FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor:
                                    const Color.fromARGB(255, 80, 80, 80)
                                        .withOpacity(0.7),
                                elevation: 2.0,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "가이드 위치 조회",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
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

  void goGroupPlanPage() {
    if (groupdetail.tourId == null || selectedTour == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("그룹에 지정된 계획이 없습니다."),
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GroupPlanPage(selectedTour: selectedTour!)));
    }
  }
}
