/*PlanCreatePage API 연동 중*/
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/tour/tourListPage.dart';

class PlanCreatePage extends StatefulWidget {
  PlanCreatePage({Key? key, required this.dayCount}) : super(key: key);
  var dayCount = 1;
  static const storage = FlutterSecureStorage();
  @override
  State<PlanCreatePage> createState() => _PlanCreatePageState();
}

class _PlanCreatePageState extends State<PlanCreatePage> {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  late String url;
  var tourId = 0;

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
    userInfo = await PlanCreatePage.storage.read(key: 'login');
    url = (await PlanCreatePage.storage.read(key: 'address'))!;
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
  //

  List<Map<String, String>> PlanCreatePageList = [];

  Future<void> _onDayPressed(int day) async {
    print('Day $day');

    try {
      final url = Uri.parse("http://34.83.150.5/PlanCreatePage");
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
          content: Text('일정이 성공적으로 추가되었습니다!'),
        );
        var responseBody = jsonDecode(response.body);

        List<String> timeParts = timeController.text.split(":");

        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        int PlanCreatePageId = responseBody["PlanCreatePageId"];

        Map<String, dynamic> PlanCreatePageItem = {
          "tourId": tourId,
          "day": widget.dayCount,
          "time": {
            "hour": hour,
            "minute": minute,
          },
          "title": titleController.text,
          "content": contentController.text,
          "PlanCreatePageId": PlanCreatePageId.toString(),
        };
        // bool dayExists =
        //     PlanCreatePageList.any((element) => element["day"] == "Day $day");
      } else {
        SnackBar(
          content: Text('일정 추가 실패. 상태 코드: ${response.statusCode}'),
        );
      }
    } catch (e) {
      SnackBar(
        content: Text('API 호출 중 오류 발생: $e'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SingleChildScrollView(),
        // PlanCreatePageDay
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                await _onDayPressed(widget.dayCount);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  color: Colors.white,
                  child: Text(
                    'Day ${widget.dayCount}',
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
              await _onDayPressed(widget.dayCount);
              Navigator.pushNamed(context, '/main/tour');
            }, //저장하고 다시 TourListPage로 돌아감. 물론 값을 갖고 가야하는디...ㅋㅋㅋ
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
