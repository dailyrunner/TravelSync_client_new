import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

class NoticeEditPage extends StatefulWidget {
  final int noticeId;
  final int groupId;
  const NoticeEditPage(
      {super.key, required this.noticeId, required this.groupId});

  @override
  State<NoticeEditPage> createState() => _NoticeEditPageState();
}

class _NoticeEditPageState extends State<NoticeEditPage> {
  final TextEditingController noticeTitleController = TextEditingController();
  late String? url;
  late DateTime _setDate;
  late int _setHour;
  late int _setMinute;
  late Notice thisNotice;
  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;
  Future? _noticeInfoFuture;

  @override
  void initState() {
    super.initState();
    _noticeInfoFuture = checkUserState();
  }

  checkUserState() async {
    userKey = await storage.read(key: 'login');
    url = await storage.read(key: 'address');
    if (userKey == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userKey);
      await getNotice();
    }
  }

  getNotice() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
        Uri.parse('$url/notice/${widget.groupId}'),
        headers: header,
      );
      if (response.statusCode == 200) {
        final notices = jsonDecode(utf8.decode(response.bodyBytes));
        for (var notice in notices) {
          if (notice['noticeId'] == widget.noticeId) {
            thisNotice = notice;
            await setInitData();
            break;
          }
        }
      } else {
        print('error');
      }
    } catch (e) {
      throw Error();
    }
  }

  setInitData() async {
    _setDate = DateTime.parse(thisNotice.noticeDate);
    _setHour = _setDate.hour;
    _setMinute = _setDate.minute;
  }

  // Notice 수정 api
  editNotice() async {}

  void searchLocation() {}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: _noticeInfoFuture,
            builder: (context, snapshot) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Header(textHeader: "Edit NOTICE"),
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
                                Future<TimeOfDay?> selectedTime =
                                    showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_setDate),
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
                          onPressed: editNotice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfff5fbff),
                          ),
                          child: const Text(
                            "알림 수정",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ))
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
