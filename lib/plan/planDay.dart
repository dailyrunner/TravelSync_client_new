import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/plan/createPlanBox.dart';

class PlanDay extends StatefulWidget {
  var tourId;
  PlanDay({Key? key, required this.tourId}) : super(key: key);

  static const storage = FlutterSecureStorage();

  @override
  State<PlanDay> createState() => _planDayState();
}

class _planDayState extends State<PlanDay> {
  //Api day 선언
  late String url;
  var tourId;
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
    userInfo = await PlanDay.storage.read(key: 'login');
    url = (await PlanDay.storage.read(key: 'address'))!;
    userInfo = jsonDecode(userInfo);
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }

/*    *    *    *    *    *    *    *    *    */
  Widget DayDivider() {
    return const SizedBox(
      width: 386,
      child: Divider(
        thickness: 2.0,
        color: Color.fromARGB(255, 187, 214, 255),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            DayDivider(),
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
            DayDivider(),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}
