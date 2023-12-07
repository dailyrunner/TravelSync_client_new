import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/models/tour.dart';
import 'package:travelsync_client_new/tour/createTour.dart';
import 'package:travelsync_client_new/tour/tourListPage.dart';
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
  int index = 0;

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

          // maxDay 값을 planDay에 할당
          planDay = planList.isNotEmpty
              ? planList.map((plan) => plan.day).toSet().length
              : 1;
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

  Future<void> getSelectedDayPlan(int selectedDay) async {
    // 선택한 일자의 플랜을 가져오는 함수 호출
    try {
      // 예시로 getPlanListByDay 함수 호출
      List<Plan> selectedDayPlans =
          await getPlanListByDay(widget.selectedTour.tourId, selectedDay);

      // 선택한 일자에 해당하는 플랜 리스트를 갱신
      setState(() {
        this.selectedDay = selectedDay;
        planList = selectedDayPlans;
      });
    } catch (error) {
      print('Error while fetching selected day plans: $error');
    }
  }

  Future<List<Plan>> getPlanListByDay(int tourId, int day) async {
    try {
      if (userInfo == null || userInfo["accessToken"] == null) {
        print("accessToken is null");
        throw Exception("accessToken is null");
      }
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse("$url/plan/$tourId"), // 예시 URL, 실제로 사용하는 API에 맞게 수정이 필요합니다.
        headers: header,
      );

      if (response.statusCode == 200) {
        final List<dynamic> plansJson =
            jsonDecode(utf8.decode(response.bodyBytes));

        return plansJson.map((planJson) => Plan.fromJson(planJson)).toList();
      } else {
        print('Failed to load plans for day $day. ${response.statusCode}');
        throw Exception('Failed to load plans for day $day');
      }
    } catch (error) {
      print('Error while fetching plans for day $day: $error');
      throw Exception('Failed to load plans for day $day: $error');
    }
  }

//
  Future<void> deleteTourAndPlans(int tourId) async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo['accessToken']}"
      };

      // Delete the tour
      final tourResponse = await http.delete(
        Uri.parse('$url/tour/$tourId'),
        headers: header,
      );

      if (tourResponse.statusCode == 200) {
        // Tour and plans deleted successfully
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("투어 및 플랜 삭제 완료"),
              actions: <Widget>[
                TextButton(
                  child: const Text("닫기"),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TourListPage()));
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Deletion failed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("투어 및 플랜 삭제 실패"),
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
    } catch (e) {
      // API error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("API 오류"),
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
              size: 40,
            ),
            tooltip: '뒤로가기',
            color: Colors.black,
            onPressed: () {
              navigatorKey.currentState?.pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline_outlined,
                size: 45,
              ),
              tooltip: '삭제',
              color: const Color(0xff002357),
              onPressed: () {
                // Call a function to delete the current tour
                deleteTourAndPlans(widget.selectedTour.tourId);
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const airplaneLogo(),
            const SizedBox(height: 20),
            const Header(textHeader: 'TOUR'),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      child: Text(
                        '여행사 | ${selectedTour.tourCompany}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      selectedTour.tourName,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //day 출력
                    const SizedBox(
                      width: 384,
                      child: Divider(
                        thickness: 2.0,
                        color: Color.fromARGB(255, 187, 214, 255),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          planDay,
                          (index) => GestureDetector(
                            onTap: () {
                              // setState(() {
                              //   selectedDay = index + 1;
                              // });
                              getSelectedDayPlan(index + 1);
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              // color: index + 1 == selectedDay
                              //     ? Colors.blue.withOpacity(0.5)
                              //     : Colors.transparent,
                              child: Text(
                                'Day ${index + 1}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  color: index + 1 == selectedDay
                                      ? Colors.blue[700] // 선택된 일자는 흰색으로 변경
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 384,
                      child: Divider(
                        thickness: 2.0,
                        color: Color.fromARGB(255, 187, 214, 255),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 364,
                      height: 40,
                      child: Text("$selectedDay일차",
                          style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    for (Plan plan in planList)
                      if (plan.day == selectedDay)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                left:
                                    BorderSide(color: Colors.blue, width: 2.0),
                                right:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      plan.time,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontFamily: 'YourDesiredFont',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Text(
                                      plan.planTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '세부 정보 ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Text(
                                      plan.planContent,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
    );
  }
}
