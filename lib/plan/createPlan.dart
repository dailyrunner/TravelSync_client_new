/*API 연동 중*/
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Plan extends StatelessWidget {
  Plan({Key? key, required this.dayCount}) : super(key: key);
  final int dayCount;
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  List<Map<String, String>> planList = [];

  Future<void> _onDayPressed(int day) async {
    print('Day $day');

    try {
      var url = Uri.parse("http://34.83.150.5:8080/plan");
      Map<String, dynamic> data = {
        "time": timeController.text,
        "planTitle": titleController.text,
        "planContent": contentController.text
      };
      var body = json.encode(data);
      final response = await http.post(url,
          headers: {
            "accept": "*/*",
            "Authorization":
                "Bearer eyJhbGciOiJIUzUxMiJ9.eyJleHAiOjE3MDY2MDQ5NzcsInN1YiI6InJhY2tAcmV1bmcucmluIiwidHlwZSI6IkFDQ0VTUyJ9.-Q7JmTOYySnLug9goV3bBFt2OOpyrwkf3FBVF8eSGnag75yZBy-g6pL8-KQwwn-kUJhv43wg2iTRUifFixi2sQ",
            "Content-Type": "application/json"
          },
          body: body);
      if (response.statusCode == 200) {
        const Text('일정이 성공적으로 추가되었습니다!');
        var responseBody = jsonDecode(response.body);
        int planId = responseBody["planId"];
        planList.add({
          "day": "Day $day",
          "time": timeController.text,
          "title": titleController.text,
          "content": contentController.text,
          "planId": planId.toString(),
        });
      } else {
        Text('일정 추가에 실패했습니다. 상태 코드: ${response.statusCode}');
        Text('응답 본문: ${response.body}');
      }
    } catch (e) {
      // API 호출 중에 발생할 수 있는 예외를 처리하세요
      Text('API 호출 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SingleChildScrollView(),
        // planDay
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                await _onDayPressed(dayCount);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  color: Colors.white,
                  child: Text(
                    'Day $dayCount',
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
            const Icon(
              Icons.add_circle_outline,
              size: 24,
              color: Color.fromARGB(255, 0, 110, 200),
            ),
          ],
        ),
        const SizedBox(height: 12),

        //time
        Row(
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
                controller: timeController, //
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '14:00',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 밑줄 색상 설정
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(height: 8),
        //plantitle(place)
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
                controller: titleController, //
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '인천공항 M 창구 미팅',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 밑줄 색상 설정
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
                  controller: contentController, //
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: '세부 사항을 입력하세요',
                    border: InputBorder.none, //입력 부분 밑줄 생략
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () async {
              await _onDayPressed(dayCount);
              Navigator.pushNamed(context, '/main/tour');
            },
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
                '일정 추가',
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
    );
  }
}
