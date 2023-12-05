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
    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
      //getTourList();
    });
    tourList = [];
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    // userInfo = jsonDecode(userInfo);
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    } else {
      userInfo = jsonDecode(userInfo);
      // 여기서 getTourList() 호출하면 userInfo가 확실히 채워진 후에 호출됨
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
        final tours = jsonDecode(response.body);
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
      //throw Error();
    }
  }

  Future<void> wait() async {
    await _asyncMethod();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   wait().then((_) {
  //     setState(() {
  //       getTourList();
  //     });
  //   });
  // }

  // void createTour() {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => CreateTour()));
  // }

  void deleteTour() {}

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
              size: 30,
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
            const SizedBox(height: 40),
            const Header(textHeader: 'TOUR List'), //title
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
                          const SizedBox(height: 100),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            if (tourExist)
              SizedBox(
                height: 500,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: tourList.length,
                  itemBuilder: (context, index) {
                    var tour = tourList[index];
                    return Column(
                      children: [
                        Text('TOUR 이름: ${tour.tourName}'),
                        Text('여행사: ${tour.tourCompany}'),
                        // 다른 Tour 속성들 추가 가능
                        const SizedBox(height: 10), // 각 Tour 정보 사이에 간격을 둠
                      ],
                    );
                  },
                ),
              ),
            //TOUR 만들기, TOUR 삭제 버튼
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0), // 조절 가능한 여백 값
                child: Row(
                  //여기서부터 버튼 두 개
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
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          navigatorKey.currentState
                              ?.pushNamed('/main/tour/createTour');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5FbFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: const Color.fromARGB(255, 80, 80, 80)
                              .withOpacity(0.7),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          child: Text(
                            'TOUR 삭제',
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
