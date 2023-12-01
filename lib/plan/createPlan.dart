/*API 연동 중*/
import 'package:flutter/material.dart';
import '../widgets/button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Plan extends StatelessWidget {
  Plan({Key? key, required this.dayCount}) : super(key: key);
  final int dayCount;
  final TextEditingController timeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void _onDayPressed(int day) {
    Text('Day$day');
  }

  Future<void> addPlan(String time, String place, String content) async {
    // 실제 API 엔드포인트로 교체하세요
    final apiUrl = Uri.parse('http://34.83.150.5:8080/tour');

    final headers = {
      'Authorization':
          'Bearer eyJhbGciOiJIUzUxMiJ9.eyJleHAiOjE3MDY1MTAxNDYsInN1YiI6ImxkZSIsInR5cGUiOiJBQ0NFU1MifQ.0iicmLOf8iWcZGHlW62NHsdvNllBLQjw3h7kx9FXeJbSWriQieyVChgHImB3aHAb28FVdVco5-DRSxbjbbDK4A',
      'Content-Type': 'application/json',
    };
    final payload = {
      'time': time,
      'planTitle': content,
      'planContent': content,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        const Text('일정이 성공적으로 추가되었습니다!');
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
              onTap: () {
                _onDayPressed(dayCount);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  color: Colors.white,
                  child: Text(
                    'Day$dayCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
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
                    borderSide: BorderSide(color: Colors.blue), // 밑줄 색상 설정
                  ),
                ),
                // onChanged: (value) {
                //   planList[0] = value;
                // },
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
                ),
              ),
            ),
            SizedBox(
              width: 230,
              child: TextField(
                controller: placeController,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '인천공항 M 창구 미팅',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 밑줄 색상 설정
                  ),
                ),
                // onChanged: (value) {
                //   planList[1] = value;
                // },
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
                    border: InputBorder.none, //입력 부분 밑줄 생략
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Button(
          text: '일정 추가',
          onPressed: () {
            final time = timeController.text;
            final place = placeController.text;
            final content = contentController.text;
            final myPlan = ['$time, $place, $content'];
            addPlan(time, place, content);
          },
          buttonColor: const Color.fromARGB(255, 80, 80, 80),
          width: 128.0,
        ),
      ],
    );
  }
}
