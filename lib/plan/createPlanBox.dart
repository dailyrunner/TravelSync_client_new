import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:travelsync_client_new/widget/globals.dart';

class CreatePlanBox extends StatefulWidget {
  var selectedDay;
  var tourId;
  CreatePlanBox({Key? key, required this.selectedDay}) : super(key: key);

  @override
  State<CreatePlanBox> createState() => _CreatePlanBoxState();
}

class _CreatePlanBoxState extends State<CreatePlanBox> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  late String url;
  var tourId;

  Future<void> createtour() async {
    try {
      final url = Uri.parse("http://34.83.150.5/plan");
      Map<String, dynamic> data = {
        "time": timeController.text,
        "PlanCreatePageTitle": titleController.text,
        "PlanCreatePageContent": contentController.text
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
        const SnackBar(
          content: Text('first success'),
        );
        var responseBody = jsonDecode(response.body);
        int PlanCreatePageId = responseBody["PlanCreatePageId"];

        List<String> timeParts = timeController.text.split(":");

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        Map<String, dynamic> PlanCreatePageItem = {
          "tourId": tourId,
          "day": widget.selectedDay,
          "time": timeController.text,
          "title": titleController.text,
          "content": contentController.text,
          "PlanCreatePageId": PlanCreatePageId.toString(),
        };
        navigatorKey.currentState?.pushNamed('/main/tour');
      } else {
        SnackBar(
          content: Text('first fail 상태 코드: ${response.statusCode}'),
        );
      }
    } catch (e) {
      SnackBar(
        content: Text('API error: $e'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const SizedBox(
          width: 230,
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: '14:00',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        const SizedBox(height: 8),
        //PlanCreatePagetitle(place)
        const Row(
          children: [
            Padding(
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
                decoration: InputDecoration(
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
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 14.0,
                  top: 2.0,
                  bottom: 2.0,
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '세부 사항을 입력하세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
