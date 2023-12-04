/*PlanCreatePage API 연동 중*/
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/plan/createPlanBox.dart';
import 'package:travelsync_client_new/tour/tourListPage.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/tour/createTour.dart';

class PlanCreatePage extends StatefulWidget {
  var tourId;
  PlanCreatePage({Key? key, required this.tourId}) : super(key: key);

  static const storage = FlutterSecureStorage();
  @override
  State<PlanCreatePage> createState() => _PlanCreatePageState();
}

class _PlanCreatePageState extends State<PlanCreatePage> {
  late String url;

  var dayCount = 1;
  var selectedDay = 1;
  _addDay() {
    dayCount++;
  }

/*    *    *    *    *    *    *    *    *    */
  // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = '';
  // storage에 있는 유저 정보를 저장
  @override
  initState() {
    super.initState();
    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await PlanCreatePage.storage.read(key: 'login');
    url = (await PlanCreatePage.storage.read(key: 'address'))!;
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
/*    *    *    *    *    *    *    *    *    */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              width: 384,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            SizedBox(
              height: 30,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 1; i <= dayCount; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = i; // 선택된 Day 업데이트
                          });
                        },
                        child: Container(
                          width: 80,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'Day$i', //앞서 선택한 i가 선택되면 색갈 바뀜
                            style: TextStyle(
                              color: selectedDay == i
                                  ? const Color(0xff004ECF)
                                  : Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      //두 구분 선 안에 있는 아이콘
                      onPressed: _addDay,
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              //두번째 구분선
              width: 384,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 30,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Container(
                            width: 80,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            color: Colors.white,
                            child: Text(
                              'Day $selectedDay',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          CreatePlanBox(selectedDay: selectedDay);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: Color.fromARGB(255, 0, 110, 200),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  navigatorKey.currentState?.pushNamed('/main/tour');
                }, //저장하고 다시 TourListPage로 돌아감
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF5FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor:
                      const Color.fromARGB(255, 80, 80, 80).withOpacity(0.7),
                  elevation: 2.0,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 16,
                  ),
                  child: Text(
                    '투어 생성',
                    style: TextStyle(
                      color: Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//   Future<dynamic> createplan(int day) async {
// //미 기입시 경고문
//     // if (timeController.text.isEmpty) {
//     //   showDialog(
//     //     context: context,
//     //     builder: (BuildContext context) {
//     //       // return object of type Dialog
//     //       return AlertDialog(
//     //         content: const Text("시간을 입력해주세요!"),
//     //         actions: <Widget>[
//     //           TextButton(
//     //             child: const Text("닫기"),
//     //             onPressed: () {
//     //               Navigator.pop(context);
//     //             },
//     //           ),
//     //         ],
//     //       );
//     //     },
//     //   );
//     //   return;
//     // }
//     // if (titleController.text.isEmpty) {
//     //   showDialog(
//     //     context: context,
//     //     builder: (BuildContext context) {
//     //       // return object of type Dialog
//     //       return AlertDialog(
//     //         content: const Text("투어 장소를 입력해주세요!"),
//     //         actions: <Widget>[
//     //           TextButton(
//     //             child: const Text("닫기"),
//     //             onPressed: () {
//     //               Navigator.pop(context);
//     //             },
//     //           ),
//     //         ],
//     //       );
//     //     },
//     //   );
//     //   return;
//     // }
