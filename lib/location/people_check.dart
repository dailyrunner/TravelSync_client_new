import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/location/one_location.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/locationinfo.dart';
import 'package:travelsync_client_new/models/userinfo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

class PeopleCheck extends StatefulWidget {
  const PeopleCheck({super.key});

  @override
  State<PeopleCheck> createState() => _PeopleCheckState();
}

class _PeopleCheckState extends State<PeopleCheck> {
  late String url;
  bool locationExist = false;
  List<LocationCheck> locationList = [];
  int notNear = 0;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userKey = ''; // storage에 있는 유저 정보를 저장
  dynamic userInfo = '';
  dynamic groupId = '';
  String peopleNearby = '로딩중..';

  UserInfo realUserInfo = UserInfo('로딩중.....', '로딩중...', '로딩중.......');

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userKey = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    groupId = await storage.read(key: 'groupId');

    // user의 정보가 없다면 로그인 페이지로 넘어가게 합니다.
    if (userKey == null) {
      navigatorKey.currentState?.pushNamed('/');
    } else {
      userInfo = jsonDecode(userKey);
      await getUserInfo();
      await getCountmember();
      await waitForLocation();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _asyncMethod();
    });
  }

  Future<void> wait() async {
    await waitForLocation();
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
            onPressed: () {
              locationList = [];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupMainPage(groupId: int.parse(groupId)),
                ),
              );
              //navigatorKey.currentState?.pop();
            },
          ),
        ),
        body: Column(
          children: [
            const airplaneLogo(),
            Container(
              height: 10,
            ),
            const Header(textHeader: "인원 점검"),
            Container(
              height: 80,
            ),
            Text(
              "${realUserInfo.name} 가이드님 주변에",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "$peopleNearby명이 모여있습니다.",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              height: 80,
            ),
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 2.0,
                  ),
                ),
              ),
              width: 360.0,
            ),
            Container(
              height: 30,
            ),
            SizedBox(
              height: 300,
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
                  if (!locationExist) {
                    return Column(
                      children: [
                        Container(
                          height: 110,
                        ),
                        const Text(
                          '근처에 사람들이 모두 모여있습니다.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF003157),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemCount: notNear,
                      itemBuilder: (context, index) {
                        var location = locationList[index];
                        return Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                ),
                                Text(
                                  "${location.userName} 여행객",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF003157),
                                  ),
                                ),
                                Container(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    storage.write(
                                        key: 'latitude',
                                        value: location.latitude.toString());
                                    storage.write(
                                        key: 'longitude',
                                        value: location.longitude.toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OneLocation(),
                                      ),
                                    );
                                  },
                                  child: const Text('위치 조회'),
                                ),
                              ],
                            ),
                            Container(
                              height: 5,
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getUserInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      String userId = userInfo["accountName"];
      final response =
          await http.get(Uri.parse("$url/user/info/$userId"), headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        realUserInfo = UserInfo.fromJson(responseBody);
        setState(() {});
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text(" 오류가 발생했습니다."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("닫기"),
                      onPressed: () {
                        navigatorKey.currentState?.pop();
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
                      navigatorKey.currentState?.pop();
                    },
                  ),
                ],
              );
            },
          ));
    }
  }

  getCountmember() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}",
        "Content-Type": "application/json",
      };

      final response = await http.get(
          Uri.parse("$url/location/countmember/$groupId"),
          headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        peopleNearby = responseBody.toString();
        print(peopleNearby);
        setState(() {});
      } else {
        if (!mounted) return;
        navigatorKey.currentState?.pop();
      }
    } catch (e) {
      if (!mounted) return;
      Future.microtask(() => showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("그룹정보 호출 오류"),
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

  waitForLocation() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse('$url/location/checkmember/$groupId'),
        headers: header,
      );
      if (response.statusCode == 200) {
        notNear = 0;
        final locations = jsonDecode(utf8.decode(response.bodyBytes));
        for (var location in locations) {
          LocationCheck locationCheck = LocationCheck.fromJson(location);
          if (locationCheck.isNear == false) {
            locationList.add(LocationCheck.fromJson(location));
            locationExist = true;
            notNear++;
          }
        }
      } else {
        print('error');
      }
    } catch (e) {
      throw Error();
    }
  }
}
