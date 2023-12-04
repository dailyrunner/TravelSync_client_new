/*Tour API 연동 중*/
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import '../widgets/header.dart';
import '../plan/createPlan.dart';

//////API/////
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'dart:convert';

class CreateTour extends StatefulWidget {
  const CreateTour({Key? key}) : super(key: key);
  @override
  State<CreateTour> createState() => CreateTourState();
}

class CreateTourState extends State<CreateTour> {
  final TextEditingController tourNameController = TextEditingController();
  final TextEditingController tourCompanyController = TextEditingController();
  int dayCount = 1;
  var selectedDay = 1;
  //
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
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
  //

  void _addDay() {
    setState(() {
      dayCount++;
    });
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
            const TourName(),
            const SizedBox(height: 20),
            const SizedBox(
              width: 386,
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
              width: 386,
              child: Divider(
                thickness: 2.0,
                color: Color.fromARGB(255, 187, 214, 255),
              ),
            ),
            const SizedBox(height: 12),
            PlanCreatePage(dayCount: selectedDay)
          ],
        ),
      ),
    );
  }
}

class TourName extends StatelessWidget {
  const TourName({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            // SingleChildScrollView(),
            Padding(
              padding: EdgeInsets.only(left: 44),
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
              width: 220,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '일본 도쿄 투어',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 80),
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
              width: 220,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '하나 투어',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
