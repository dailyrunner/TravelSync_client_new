import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:travelsync_client_new/models/notice.dart';
import 'package:travelsync_client_new/notice/notice_page.dart';
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
  double latitude = 0, longitude = 0;
  Set<Marker> marker = {};

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
          if (notice["noticeId"] == widget.noticeId) {
            thisNotice = Notice.fromJson(notice);
            await setInitData();
            break;
          }
        }
      } else {
        print('error');
      }
    } catch (e, s) {
      print("exception: $e\n");
      print("stack trace: $s\n");
      throw Error();
    }
  }

  setInitData() async {
    _setDate = DateTime.parse(thisNotice.noticeDate);
    _setHour = _setDate.hour;
    _setMinute = _setDate.minute;
    marker = {
      Marker(
          markerId: const MarkerId('selected'),
          position: LatLng(
            thisNotice.noticeLatitude,
            thisNotice.noticeLongitude,
          ))
    };
    latitude = thisNotice.noticeLatitude;
    longitude = thisNotice.noticeLongitude;
  }

  getPoint(LatLng tappedPoint) {
    setState(() {
      marker = {
        Marker(
          markerId: const MarkerId('selected'),
          position: tappedPoint,
        )
      };
      latitude = tappedPoint.latitude;
      longitude = tappedPoint.longitude;
    });
  }

  // Notice 수정 api
  editNotice() async {
    if (noticeTitleController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            content: const Text("위치를 입력해주세요."),
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
      String finalTime = DateFormat('yyyy-MM-dd hh:mm').format(DateTime(
          _setDate.year, _setDate.month, _setDate.day, _setHour, _setMinute));
      Map<String, dynamic> data = {
        'noticeId': widget.noticeId,
        'groupId': widget.groupId,
        'noticeDate': finalTime,
        'noticeTitle': noticeTitleController.text,
        'noticeLatitude': latitude,
        'noticeLongitude': longitude,
      };
      var body = json.encode(data);
      final response = await http.post(Uri.parse("$url/notice"),
          headers: {
            "accept": "*/*",
            "Authorization": "Bearer ${userInfo["accessToken"]}",
            "Content-Type": "application/json"
          },
          body: body);
      if (response.statusCode == 200) {
        if (!mounted) return;

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
                                  NoticePage(groupId: widget.groupId)));
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

  deleteNotice() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo['accessToken']}"
      };
      final response = await http
          .delete(Uri.parse('$url/notice/${widget.noticeId}'), headers: header);
      if (response.statusCode == 200) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("알림 삭제 완료"),
              actions: <Widget>[
                TextButton(
                  child: const Text("닫기"),
                  onPressed: () async {
                    Navigator.pop(context);
                    Future.microtask(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NoticePage(groupId: widget.groupId)));
                    });
                  },
                ),
              ],
            );
          },
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: const Text("알림 삭제 실패"),
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
      Error();
    }
  }

  deleteNoticeAlert() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("정말로 알림을 삭제할까요?"),
            actions: <Widget>[
              TextButton(
                child: Text("네",
                    style: TextStyle(
                      color: Colors.grey[400],
                    )),
                onPressed: () {
                  Navigator.pop(context);
                  deleteNotice();
                },
              ),
              TextButton(
                child: const Text("아니오",
                    style: TextStyle(
                      color: Colors.red,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void searchLocation() {}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
            future: _noticeInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Future Error!\n${snapshot.error}"),
                );
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Header(textHeader: "Edit NOTICE"),
                      const SizedBox(
                        height: 40,
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
                              "위치",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 60,
                          ),
                          SizedBox(
                            width: 120,
                            height: 30,
                            child: TextField(
                              controller: noticeTitleController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
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
                          const SizedBox(
                            width: 70,
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
                                  initialDate:
                                      DateTime.parse(thisNotice.noticeDate),
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
                          const SizedBox(width: 20)
                        ],
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
                          const SizedBox(width: 85),
                          TextButton(
                            child: Text("$_setHour : $_setMinute"),
                            onPressed: () async {
                              Future<TimeOfDay?> selectedTime = showTimePicker(
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
                          const SizedBox(width: 32),
                        ],
                      ),
                      SizedBox(
                        height: 410,
                        width: 320,
                        child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(latitude, longitude),
                                zoom: 15.0),
                            onTap: getPoint,
                            markers: marker),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: deleteNoticeAlert,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xfff5fbff),
                            ),
                            child: const Text(
                              "알림 삭제",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
