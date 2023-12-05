import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:travelsync_client_new/models/plan.dart';

import 'package:flutter/material.dart';
import 'package:travelsync_client_new/widget/globals.dart';

class CreatePlanBox extends StatefulWidget {
  CreatePlanBox({Key? key, required this.selectedDay, required this.tourId})
      : super(key: key);
  int selectedDay;
  int tourId;
  //Plan realPlan = Plan(0, 0, 0, '로딩중', '로딩중', '로딩중');

  @override
  State<CreatePlanBox> createState() => _CreatePlanBoxState();
}

class _CreatePlanBoxState extends State<CreatePlanBox> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  var planId = 0;
  /*    *    *    *    *    *    *    *    *    */
  late String url;
  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = ''; // storage에 있는 유저 정보를 저장
  //flutter_secure_storage 사용을 위한 초기화 작업
  @override
  void initState() {
    super.initState();
    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    userInfo = jsonDecode(userInfo);
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
  /*    *    *    *    *    *    *    *    *    */

  createplans() async {
    if (timeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("시간을 입력해주세요."),
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
    if (titleController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("장소를 입력해주세요."),
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
        "tourId": widget.tourId,
        "day": widget.selectedDay,
        "time": timeController.text,
        "title": titleController.text,
        "content": contentController.text
      };
      var body = json.encode(data);
      final response = await http.post(Uri.parse('$url/plan'),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer ${userInfo["accessToken"]}",
            "Content-Type": "application/json"
          },
          body: body);

      if (response.statusCode == 200) {
        if (mounted) {
          dynamic responseBody = jsonDecode(response.body);
          setState(() {
            planId = responseBody["planId"];
            print(planId);
          });
          print('성공 planId: $planId');
        }

        // 응답 바디에서 TourID 추출
        // TourID와 무언가를 수행, 예를 들면 출력하거나 저장하기
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 48),
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
                controller: timeController,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '14:00',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            //PlanCreatePagetitle(place)
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
                    controller: titleController,
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
                      controller: contentController,
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
      ),
    );
  }
}
