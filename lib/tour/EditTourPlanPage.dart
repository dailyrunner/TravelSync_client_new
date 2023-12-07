import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/models/tour.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/tour/tourListPage.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class EditTourPlanPage extends StatefulWidget {
  final int tourId;
  final int planId;
  final int day;
  // Tour realTour = Tour(tourId, 'tourId.tourName', 'tourId.tourCompany');
  // Plan realPlan = Plan(tourId, 'tourId.tourName', 'tourId.tourCompany');

  const EditTourPlanPage(
      {required this.tourId, required this.planId, required this.day, Key? key})
      : super(key: key);

  @override
  _EditTourPlanPageState createState() => _EditTourPlanPageState();
}

class _EditTourPlanPageState extends State<EditTourPlanPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  String _formatTime(String time) {
    DateTime parsedTime = DateTime.parse("2022-01-01 $time:00");
    return "${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}";
  }

/*    *    *    *    *    *    *    *    *    */
  late String url;
  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = '';
  @override
  void initState() {
    super.initState();
    _asyncMethod();
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

  void saveEditedPlan() async {
    if (titleController.text.isEmpty || timeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("시간이나 장소 작성을 까먹으셨나요?"),
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
    }
    try {
      final response = await http.put(
        Uri.parse('$url/plan'),
        headers: {
          "accept": "*/*",
          "Authorization": "Bearer ${userInfo["accessToken"]}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'planId': widget.planId,
          'tourId': widget.tourId,
          'day': widget.day,
          'planTitle': titleController.text,
          'time': _formatTime(timeController.text),
          'planContent': contentController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("플랜이 수정되었습니다."),
              actions: <Widget>[
                TextButton(
                  child: const Text("닫기"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TourListPage(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
        setState(() {
          titleController.clear();
          timeController.clear();
          contentController.clear();
        });
        print('성공');
      } else {
        print('플랜 수정 실패. 상태 코드: ${response.statusCode}');
        print('응답 바디: ${response.body}');
      }
    } catch (error) {
      print('플랜 수정 오류: $error');
    }
  }

  // Tour? selectedTour;
  // fetchTourDetails() async {
  //   String userId = userInfo["accountName"].toString();
  //   try {
  //     final tourResponse = await http.get(
  //       Uri.parse('$url/tour/list/$userId'),
  //       headers: {
  //         "accept": "*/*",
  //         "Authorization": "Bearer ${userInfo["accessToken"]}",
  //       },
  //     );

  //     if (tourResponse.statusCode == 200) {
  //       final List<dynamic> tourData = jsonDecode(tourResponse.body);
  //       if (tourData.isNotEmpty) {
  //         setState(() {
  //           selectedTour = Tour.fromJson(tourData[0]);
  //         });
  //       }
  //     } else {
  //       print('투어 정보 가져오기 실패. 상태 코드: ${tourResponse.statusCode}');
  //       print('응답 바디: ${tourResponse.body}');
  //     }
  //   } catch (error) {
  //     print('투어 정보 가져오기 오류: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    print('Editing plan for day: ${widget.day}');
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TourListPage(),
                ),
              );
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const airplaneLogo(),
            const SizedBox(height: 20),
            const Header(textHeader: 'Edit PLAN'),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "시간과 장소는 필수항목입니다.",
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff002357)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // if (selectedTour != null)
                    //   SizedBox(
                    //     child: Text(
                    //       '여행사 | ${selectedTour!.tourCompany}',
                    //       style: const TextStyle(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // if (selectedTour != null)
                    //   Text(
                    //     selectedTour!.tourName,
                    //     style: const TextStyle(
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: '시간',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: '장소'),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: contentController,
                        decoration: const InputDecoration(labelText: '내용'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          saveEditedPlan();
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
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Text(
                            '수정 완료',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
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
    );
  }
}
