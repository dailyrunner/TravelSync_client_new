/*Tour API 연동 중*/
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/tour.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import '../widgets/header.dart';
import '../plan/createPlan.dart';

//access token:eyJhbGciOiJIUzUxMiJ9.eyJleHAiOjE3MDM2ODkwMjQsInN1YiI6InN0ckBuYXZlci5jb20iLCJ0eXBlIjoiQUNDRVNTIn0.BiOeGRixTHEdTjL1CW4dQ2tM0QT-rQoJaQm8H2lHwqQtiXgxG4cg4sQDAjI89eI_sC2l2q_rFoJcz_HOmYleXA
//

class CreateTour extends StatefulWidget {
  var tourId = '';
  Tour realTour = Tour(0, '로딩중', '로딩중');

  CreateTour({Key? key}) : super(key: key);
  @override
  State<CreateTour> createState() => _CreateTourState();
}

class _CreateTourState extends State<CreateTour> {
  final TextEditingController tourNameController = TextEditingController();
  final TextEditingController tourCompanyController = TextEditingController();
  late String url;
  int tourId = 0;

  /*    *    *    *    *    *    *    *    *    */

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
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
  /*    *    *    *    *    *    *    *    *    */

  Future<void> createtour() async {
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

      // 요청이 성공했는지 확인 (상태 코드 200)
      if (response.statusCode == 200) {
        if (!mounted) return;
        dynamic responseBody = jsonDecode(response.body);
        setState(() {
          tourId = int.parse(responseBody["tourId"]); // tourId 설정
        });
        print('와씨됐다!');
        // 응답 바디에서 TourID 추출
        // TourID와 무언가를 수행, 예를 들면 출력하거나 저장하기
      } else {
        // 요청이 실패한 경우 에러 처리
        print('여행 생성 실패. 상태 코드: ${response.statusCode}');
      }
    } catch (error) {
      // API 요청 중 발생한 예외 처리
      print('여행 생성 오류: $error');
    }
  }

//  Map<String, String> CreateTours = [];

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
            SizedBox(
              child: Column(
                children: [
                  Row(
                    children: [
                      // SingleChildScrollView(),
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          'TOUR 이름    ',
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
                          '여행사    ',
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
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ), //여기서 tourId 받기
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // PlanCreatePage(tourId: tourId), /* */
          ],
        ),
      ),
    );
  }
}
