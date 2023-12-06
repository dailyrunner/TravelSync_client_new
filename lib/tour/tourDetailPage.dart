import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/models/tour.dart';
import 'package:travelsync_client_new/plan/planDay.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class TourDetailPage extends StatefulWidget {
  final Tour selectedTour;

  const TourDetailPage({required this.selectedTour, Key? key})
      : super(key: key);

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  dynamic selectedTour;
  late List<Plan> planList = [];
  int planDay = 1;
  //late List<Tour> tourList = [];
  static const storage = FlutterSecureStorage();
  // dynamic userKey = '';
  dynamic userInfo = '';
  late String? url;
  int selectedDay = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
      getTourPlans(widget.selectedTour.tourId);
      //getTourInfo(widget.selectedTour.tourId);
    });
  }

  _asyncMethod() async {
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    // userInfo = jsonDecode(userInfo);
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    } else {
      userInfo = jsonDecode(userInfo);
      // 여기서 getTourList() 호출하면 userInfo가 확실히 채워진 후에 호출됨,
      setState(() {});
      getTourPlans(widget.selectedTour.tourId);
    }
  }

  getTourPlans(int tourId) async {
    try {
      if (userInfo == null || userInfo["accessToken"] == null) {
        // userInfo가 null이거나 "accessToken" 키에 대한 값이 null인 경우
        // 에러를 방지하기 위해 처리
        print("accessToken is null");
        return;
      }
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response =
          await http.get(Uri.parse("$url/plan/$tourId"), headers: header);

      if (response.statusCode == 200) {
        final List<dynamic> plansJson =
            jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          planList =
              plansJson.map((planJson) => Plan.fromJson(planJson)).toList();
        });
      } else {
        print('Failed to load plans. ${response.statusCode}');
      }
    } catch (error) {
      print('Error while fetching plans: $error');
    }
  }

  Future<void> getTourInfo(int tourId) async {
    try {
      if (userInfo == null || userInfo["accessToken"] == null) {
        // userInfo가 null이거나 "accessToken" 키에 대한 값이 null인 경우
        // 에러를 방지하기 위해 처리
        print("accessToken is null");
        throw Exception("accessToken is null");
      }
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response =
          await http.get(Uri.parse("$url/tour/list/$tourId"), headers: header);

      if (response.statusCode == 200) {
        final Map<String, dynamic> tourJson =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          selectedTour = Tour.fromJson(tourJson);
        });
      } else {
        print('Failed to load tour. ${response.statusCode}');
        throw Exception('Failed to load tour');
      }
    } catch (error) {
      // 에러 처리
      print('Error while fetching tour info: $error');
      throw Exception('Failed to load tour info $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTour = widget.selectedTour;
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
            const airplaneLogo(),
            const SizedBox(height: 20),
            const Header(textHeader: 'TOUR'),
            const SizedBox(height: 8),
            //tour, plan detail
            SizedBox(
              child: Text(
                '여행사 | ${selectedTour.tourCompany}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(
              width: 380,
              child: Text(
                selectedTour.tourName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Divider(
              thickness: 2.0,
              color: Color.fromARGB(255, 187, 214, 255),
            ),
            // Day 동적 생성 부분
            SizedBox(
              height: 30,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 1; i <= planDay; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = i; // 선택된 Day 업데이트
                          });
                        },
                        child: Container(
                          width: 80,
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
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
            const Divider(
              thickness: 2.0,
              color: Color.fromARGB(255, 187, 214, 255),
            ),
            const SizedBox(
              height: 12,
            ),
            // 선택된 Day에 해당하는 계획 출력
            if (selectedDay > 0 && selectedDay <= planList.length)
              SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$selectedDay일차', // Display the selected day here
                      style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: 2, // 세로 선의 너비
                          color: Colors.blue, // 세로 선의 색상
                          margin: const EdgeInsets.only(
                              right: 10), // 세로 선과 텍스트 간의 간격 조절
                        ),
                        // 해당 Day의 상세 정보 출력
                        Text(
                          '${planList[selectedDay - 1].time}    ${planList[selectedDay - 1].planTitle}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),

                    // Text(
                    //   '일정 내용: ${planList[selectedDay - 1].planContent}',
                    //   style: const TextStyle(
                    //     fontSize: 16,
                    //     color: Colors.black,

                    //   ),
                    // ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
