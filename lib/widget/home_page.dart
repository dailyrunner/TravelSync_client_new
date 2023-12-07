import 'package:flutter/material.dart';
import 'dart:convert'; // JSON Encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_create_page.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/group.dart';
import 'package:travelsync_client_new/tour/tourListPage.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:http/http.dart' as http;
import 'package:travelsync_client_new/widget/settings_page.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String url;
  bool groupExist = false;
  List<Group> groupList = [];
  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;

    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    } else {
      userInfo = jsonDecode(userInfo);
      await waitForGroup();
    }
  }

  Future<void> wait() async {
    await _asyncMethod();
  }

  waitForGroup() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse('$url/group/info/${userInfo["accountName"]}'),
        headers: header,
      );
      if (response.statusCode == 200) {
        final notices = jsonDecode(utf8.decode(response.bodyBytes));
        for (var notice in notices) {
          groupList.add(Group.fromJson(notice));
          groupExist = true;
        }
      } else {
        print('error');
      }
    } catch (e) {
      throw Error();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'settings',
              color: Colors.black,
              iconSize: 45,
            ),
          ],
        ),
        body: Column(
          children: [
            const airplaneLogo(),
            Container(
              height: 20,
            ),
            const Header(textHeader: 'Joined Group'),
            Container(
              height: 15,
            ),
            SizedBox(
              height: 460,
              child: FutureBuilder(
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
                    if (!groupExist) {
                      return Column(
                        children: [
                          Container(
                            height: 110,
                          ),
                          const Text(
                            '현재 가입되어 있는 그룹이 없습니다.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF003157),
                            ),
                          ),
                          const Text(
                            '초대 링크를 받아 그룹에 들어가거나',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF003157),
                            ),
                          ),
                          const Text(
                            '그룹을 직접 만들어보세요!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF003157),
                            ),
                          ),
                          Container(
                            height: 30,
                          ),
                          Container(
                            width: 83,
                            height: 50,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/group_icon.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return ListView.separated(
                        scrollDirection: Axis.vertical,
                        itemCount: groupList.length,
                        itemBuilder: (context, index) {
                          var group = groupList[index];
                          return TextButton(
                            onPressed: () {
                              Future.microtask(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupMainPage(
                                            groupId: group.groupId)));
                              });
                            },
                            child: Container(
                              width: 372,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 80, 80, 80)
                                        .withOpacity(0.5),
                                    blurRadius: 2.0,
                                    spreadRadius: 1,
                                    offset: const Offset(1, 1.5),
                                  ),
                                ],
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 8, left: 30, right: 30),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Column(
                                            children: [
                                              Icon(Icons.flag_outlined,
                                                  size: 24,
                                                  color: Colors.black),
                                              SizedBox(height: 4),
                                              Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 24,
                                                  color: Colors.black),
                                              SizedBox(height: 4),
                                              Icon(Icons.person_outlined,
                                                  size: 24,
                                                  color: Colors.black),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: Container(
                                              width: 2,
                                              height: 74,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${group.groupName} | ${group.tourCompany}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter',
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${group.startDate} ~ ${group.endDate}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter',
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "가이드 ${group.guide}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter',
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
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                      );
                    }
                  }),
            ),
            //투어 생성하기 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TourListPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 45),
                backgroundColor: const Color(0xFFF5FBFF),
                shadowColor:
                    const Color.fromARGB(255, 80, 80, 80).withOpacity(0.7),
                elevation: 2.0,
              ),
              child: const Text(
                '여행계획 관리',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 10,
            ),
            //그룹 생성하기 버튼
            ElevatedButton(
              onPressed: () {
                // 버튼이 눌리면 다른 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupCreatePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 45),
                backgroundColor: const Color(0xFFF5FBFF),
                shadowColor:
                    const Color.fromARGB(255, 80, 80, 80).withOpacity(0.7),
                elevation: 2.0,
              ),
              child: const Text(
                '그룹 생성하기',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
