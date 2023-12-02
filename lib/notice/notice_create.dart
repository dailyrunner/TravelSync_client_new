import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

class NoticeCreatePage extends StatefulWidget {
  final int groupId;
  const NoticeCreatePage({super.key, required this.groupId});

  @override
  State<NoticeCreatePage> createState() => _NoticeCreatePageState();
}

class _NoticeCreatePageState extends State<NoticeCreatePage> {
  final TextEditingController noticeTitleController = TextEditingController();
  late String? url;
  DateTime _setDate = DateTime.now();
  int _setHour = DateTime.now().hour;
  int _setMinute = DateTime.now().minute;
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;

  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserState();
    });
  }

  checkUserState() async {
    userKey = await storage.read(key: 'login');
    url = await storage.read(key: 'address');
    if (userKey == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userKey);
    }
  }

  void searchLocation() {}
  createNotice() async {
    try {
      String finalTime = DateTime(
              _setDate.year, _setDate.month, _setDate.day, _setHour, _setMinute)
          .toIso8601String();
      Map<String, dynamic> data = {
        'groupId': widget.groupId,
        'noticeDate': finalTime,
        'noticeTitle': noticeTitleController.text,
        'noticeLatitude': 0,
        'noticeLongitude': 0,
      };
      var body = json.encode(data);
      final response = await http.post(Uri.parse("$url/notice"),
          headers: {"accept": "*/*", "Content-Type": "application/json"},
          body: body);
      if (response.statusCode == 200) {
        if (!mounted) return;
        var responseBody = jsonDecode(response.body);
        int groupId = responseBody["groupId"];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("알림 추가 완료"),
              actions: <Widget>[
                TextButton(
                  child: const Text("닫기"),
                  onPressed: () {
                    Navigator.pop(context);
                    Future.microtask(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GroupMainPage(groupId: groupId)));
                    });
                  },
                ),
              ],
            );
          },
        );

        return;
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("http 통신 오류"),
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
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("api오류"),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Header(textHeader: "Create NOTICE"),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 3,
                      child: Text(
                        "위치",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: TextField(
                        controller: noticeTitleController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    Flexible(
                        child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: searchLocation,
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 3,
                      child: Text(
                        "날짜",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: TextButton(
                        child: Text(
                          "${_setDate.toLocal()}".split(' ')[0],
                        ),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2035, 12, 31),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _setDate = selectedDate;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 3,
                      child: Text(
                        "시간",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: TextButton(
                        child: Text("$_setHour : $_setMinute"),
                        onPressed: () async {
                          Future<TimeOfDay?> selectedTime = showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          selectedTime.then((timeOfDay) {
                            setState(() {
                              if (timeOfDay != null) {
                                _setHour = timeOfDay.hour;
                                _setMinute = timeOfDay.minute;
                              }
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                    onPressed: createNotice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff5fbff),
                    ),
                    child: const Text(
                      "알림 추가",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
