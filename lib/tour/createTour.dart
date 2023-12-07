/*Tour API 연동 중*/
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import '../widgets/header.dart';

//////API/////
import 'package:travelsync_client_new/models/tour.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class CreateTour extends StatefulWidget {
  CreateTour({Key? key}) : super(key: key);
  // int tourId = 0;
  Tour realTour = Tour(0, '로딩중', '로딩중');
  //
  Plan realPlan = Plan(0, 0, 0, '로딩중', '로딩중', '로딩중');

  @override
  State<CreateTour> createState() => CreateTourState();
}

/* * * * * * 투어 부분 * * * * * */
var dayCount = 1;
var selectedDay;
int tourId = 0;

class CreateTourState extends State<CreateTour> {
  final TextEditingController tourNameController = TextEditingController();
  final TextEditingController tourCompanyController = TextEditingController();

  /*    *    *    *    *    *    *    *    *    */
  late String url;
  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장
  @override
  void initState() {
    super.initState();
    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    userInfo = jsonDecode(userInfo);
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
  /*    *    *    *    *    *    *    *    *    */

  void createtour() async {
    if (tourNameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("TOUR을 입력해주세요."),
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
    if (tourCompanyController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("여행사를 입력해주세요."),
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
    try {
      Map<String, dynamic> data = {
        'tourName': tourNameController.text,
        'tourCompany': tourCompanyController.text,
      };
      var body = json.encode(data);
      final response = await http.post(Uri.parse('$url/tour'),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer ${userInfo["accessToken"]}",
            "Content-Type": "application/json"
          },
          body: body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        dynamic responseBody = jsonDecode(response.body);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("Tour 이름과 여행사가 등록되었습니다."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
        setState(() {
          tourId = responseBody["tourId"]; // tourId 설정
          print(tourId);
        });
        print('성공 tourId: $tourId');
      } else {
        // 요청이 실패한 경우 에러 처리
        print('여행 생성 실패. 상태 코드: ${response.statusCode}');
        print('응답 바디: ${response.body}');
      }
    } catch (error) {
      // API 요청 중 발생한 예외 처리
      print('여행 생성 오류: $error');
    }
  }

/* * * * * 플랜부분 * * * * */

  _addDay() {
    setState(() {
      dayCount++;
    });
  }

/* * */
  final TextEditingController plantitleController = TextEditingController();
  final TextEditingController plantimeController = TextEditingController();
  final TextEditingController plancontentController = TextEditingController();
  var planId = 0;
  var selectedDay = 1;

  /*앞서 선언된 곳은 없애줌*/

  String _formatTime(String time) {
    DateTime parsedTime = DateTime.parse("2022-01-01 $time:00");
    return "${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}";
  }

  void createplan() async {
    if (plantitleController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("Plan장소를 입력해주세요."),
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
    if (plantimeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("Plan시간을 입력해주세요."),
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
    try {
      Map<String, dynamic> data = {
        "tourId": tourId,
        "day": selectedDay,
        'planTitle': plantitleController.text,
        'time': _formatTime(plantimeController.text),
        'planContent': plancontentController.text,
      };

      var body = json.encode(data);
      final response = await http.post(Uri.parse('$url/plan'),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer ${userInfo["accessToken"]}",
            "Content-Type": "application/json"
          },
          body: body);

      // 요청이 성공했는지 확인 (상태 코드 200)
      if (response.statusCode == 200) {
        if (!mounted) return;
        dynamic responseBody = jsonDecode(response.body);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("투어가 생성되었습니다."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () {
                      Navigator.pop(context);
                      // navigatorKey.currentState?.pushNamed('/main/tour');
                    },
                  ),
                ],
              );
            });
        setState(() {
          planId = responseBody["planId"]; // tourId 설정
          print(planId);
          plantitleController.clear();
          plantimeController.clear();
          plancontentController.clear();
        });
        print('성공: $planId');

        // 응답 바디에서 TourID 추출
        // TourID와 무언가를 수행, 예를 들면 출력하거나 저장하기
      } else {
        // 요청이 실패한 경우 에러 처리
        print('플랜 생성 실패. 상태 코드: ${response.statusCode}');
        print('응답 바디: ${response.body}');
      }
    } catch (error) {
      // API 요청 중 발생한 예외 처리
      print('플랜 생성 오류: $error');
    }
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
              size: 30,
            ),
            tooltip: '뒤로가기',
            color: Colors.black,
            onPressed: () {
              navigatorKey.currentState?.pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SingleChildScrollView(),
            const airplaneLogo(),
            const SizedBox(height: 20),
            const Header(textHeader: 'Create TOUR'),
            const SizedBox(height: 30),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'TOUR 이름      ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: tourNameController,
                    decoration: const InputDecoration(
                      hintText: '일본 도쿄 투어',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 66),
                  child: Text(
                    '여행사      ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: tourCompanyController,
                    decoration: const InputDecoration(
                      hintText: '하나 투어',
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: TextButton(
                    onPressed: (createtour),
                    child: const Text(
                      "확인",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 384,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Expanded(
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  'Day$i',
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
                        ],
                      ),
                    ),
                  ),
                  IconButton(
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
            const SizedBox(
              width: 384,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            /* 플랜 값 받는 중 */
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        width: 60,
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
                    IconButton(
                      onPressed: () {
                        createplan();
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
                Column(
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Text(
                            '시간   ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: plantimeController,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: '14:00',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Text(
                            '장소   ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: plantitleController,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: '인천공항 M 창구 미팅',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    //content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 340,
                          height: 180,
                          alignment: Alignment.topLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 1.0,
                                spreadRadius: 0.8,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 14.0,
                              top: 2.0,
                              bottom: 2.0,
                            ),
                            child: TextField(
                              controller: plancontentController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: '세부 사항을 입력하세요',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      createplan();
                      navigatorKey.currentState?.pushNamed('/main/tour');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: const Color.fromARGB(255, 80, 80, 80)
                          .withOpacity(0.7),
                      elevation: 2.0,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 16,
                      ),
                      child: Text(
                        '작성 완료',
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
          ],
        ),
      ),
    );
  }
}
