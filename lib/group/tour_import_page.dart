import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travelsync_client_new/models/tour.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class TourImportPage extends StatefulWidget {
  const TourImportPage({super.key, required this.userId});

  final String userId;

  @override
  State<TourImportPage> createState() => _TourImportPageState();
}

class _TourImportPageState extends State<TourImportPage> {
  late String? url;
  static const storage = FlutterSecureStorage();
  dynamic userInfo;
  List<Tour> tourList = [];
  checkUserState() async {
    userInfo = await storage.read(key: 'login');
    url = await storage.read(key: 'address');
    if (userInfo == null) {
      Navigator.pushNamed(context, '/'); // 로그인 페이지로 이동
    } else {
      userInfo = jsonDecode(userInfo);
      await waitForTourList();
    }
  }

  waitForTourList() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      final response = await http.get(
          Uri.parse("$url/tour/list/${userInfo["accountName"]}"),
          headers: header);

      if (response.statusCode == 200) {
        final tours = jsonDecode(utf8.decode(response.bodyBytes));
        for (var tour in tours) {
          tourList.add(Tour.fromJson(tour));
        }
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text("투어를 불러오는 도중 오류가 발생했습니다."),
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
            ));
      }
    } catch (e) {
      print("except: $e");
      Error();
    }
  }

  Future<void> wait() async {
    await checkUserState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          tooltip: '뒤로가기',
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: wait(),
        builder: ((context, snapshot) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Header(
                  textHeader: "Import TOUR",
                ),
                const SizedBox(
                  height: 30,
                ),
                ListView.separated(
                  scrollDirection: Axis.vertical,
                  itemCount: tourList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var tour = tourList[index];
                    return TextButton(
                      onPressed: () {
                        Navigator.pop(context, tour.tourId);
                      },
                      child: Container(
                        width: 300,
                        height: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tour.tourName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  tour.tourCompany,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
