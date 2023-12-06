import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/models/tour.dart';
import 'package:travelsync_client_new/tour/createTour.dart';
import 'package:travelsync_client_new/tour/tourDetailPage.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import '../../widgets/header.dart';

class TourListPage extends StatefulWidget {
  const TourListPage({Key? key}) : super(key: key);

  @override
  _TourListPageState createState() => _TourListPageState();
}

class _TourListPageState extends State<TourListPage> {
  late bool tourExist = true;
  List<Tour> tourList = [];
  List<Plan> planList = [];

  static const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo;
  late String? url;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
    tourList = [];
  }

  _asyncMethod() async {
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    } else {
      userInfo = jsonDecode(userInfo);
      getTourList();
      setState(() {});
    }
  }

  getTourList() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      String userId = userInfo["accountName"];
      final response =
          await http.get(Uri.parse("$url/tour/list/$userId"), headers: header);
      if (response.statusCode == 200) {
        final tours = jsonDecode(utf8.decode(response.bodyBytes));
        tourList.clear();
        if (tours.isNotEmpty) {
          tourExist = true;
          print('투어 있음');
          for (var tour in tours) {
            tourList.add(Tour.fromJson(tour));
          }
        } else {
          tourExist = false;
        }
        setState(() {});
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error is : $e');
    }
  }

  Future<void> wait() async {
    await _asyncMethod();
  }

  void navigateToTourDatail(Tour selectedTour) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TourDetailPage(selectedTour: selectedTour),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
            ),
            tooltip: '뒤로가기',
            color: Colors.black,
            onPressed: () {
              navigatorKey.currentState?.pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const airplaneLogo(),
            const SizedBox(height: 20),
            const Header(textHeader: 'TOUR List'), //title
            const SizedBox(height: 15),
            if (!tourExist)
              Column(
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '투어가 없습니다.\nTOUR 만들기로\n첫 투어를 만들어보세요!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF003157),
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          Image.asset(
                            'assets/images/tour.png',
                            height: 100,
                          ),
                          const SizedBox(height: 200),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            if (tourExist)
              SizedBox(
                height: 480,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: tourList.length,
                  itemBuilder: (context, index) {
                    var tour = tourList[index];
                    return GestureDetector(
                      onTap: () {
                        navigateToTourDatail(tour);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 12, bottom: 8, left: 30, right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 348,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 80, 80, 80)
                                        .withOpacity(0.5),
                                    blurRadius: 2.0,
                                    spreadRadius: 1,
                                    offset: const Offset(1, 1.5),
                                  ),
                                ],
                              ),
                              child: Text(
                                '  TOUR 이름 : ${tour.tourName}\n          여행사 : ${tour.tourCompany}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          navigatorKey.currentState
                              ?.pushNamed('/main/tour/createTour');
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
                            vertical: 15,
                            horizontal: 16,
                          ),
                          child: Text(
                            'TOUR 만들기',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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
