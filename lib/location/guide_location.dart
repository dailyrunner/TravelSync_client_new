import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travelsync_client_new/group/group_main_page.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/models/locationinfo.dart';
import 'package:travelsync_client_new/models/userinfo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';
import 'package:http/http.dart' as http;

class GuideLocation extends StatefulWidget {
  const GuideLocation({super.key});

  @override
  State<GuideLocation> createState() => GuideLocationState();
}

//처음 켤 때 사용자 위치 지정하는 함수, 사용자 현재 위치로 구현하고자 한다.
class GuideLocationState extends State<GuideLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  late Timer _updateTimer;
  late Position userPosition;

  late String url;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userKey = ''; // storage에 있는 유저 정보를 저장
  dynamic userInfo = '';
  dynamic groupId = '';

  UserInfo realUserInfo = UserInfo('로딩중.....', '로딩중...', '로딩중.......');
  LocationInfo realLocationInfo = LocationInfo('로딩중..', '로딩중..', 0, 0);

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userKey = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    groupId = await storage.read(key: 'groupId');

    // user의 정보가 없다면 로그인 페이지로 넘어가게 합니다.
    if (userKey == null) {
      navigatorKey.currentState?.pushNamed('/');
    } else {
      userInfo = jsonDecode(userKey);
      await getUserInfo();
    }
  }

  Future<void> _updateMarkers() async {
    // 사용자의 현재 위치를 가져오기
    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    await putUserLocation();
    await getGuideLocation();

    // 마커 설정
    Marker userMarker = Marker(
      markerId: const MarkerId('userMarker'),
      position: LatLng(userPosition.latitude, userPosition.longitude),
      infoWindow: InfoWindow(
        title: '현 위치',
        snippet: '${realUserInfo.name}님',
      ),
    );

    Marker serverMarker = Marker(
      markerId: const MarkerId('serverMarker'),
      position: LatLng(realLocationInfo.latitude, realLocationInfo.longitude),
      infoWindow: InfoWindow(
        title: '가이드 위치',
        snippet: '${realLocationInfo.userName}님',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    // 마커 갱신
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.add(userMarker);
        _markers.add(serverMarker);
      });
    }

    // 지도를 사용자의 위치로 이동
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(userPosition.latitude, userPosition.longitude)));
  }

  @override
  void initState() {
    super.initState();

    _asyncMethod();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _updateMarkers();
    });
  }

  @override
  void dispose() {
    // 위젯이 dispose 될 때 타이머를 취소
    _updateTimer.cancel();
    super.dispose();
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupMainPage(groupId: int.parse(groupId)),
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            const airplaneLogo(),
            Container(
              height: 10,
            ),
            const Header(textHeader: "위치 조회"),
            Container(
              height: 20,
            ),
            SizedBox(
              width: 380,
              height: 620,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.5584, 126.9971), // 초기 지도 위치 (가상의 예제 위치)
                  zoom: 15.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: _markers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  getUserInfo() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}"
      };
      String userId = userInfo["accountName"];
      final response =
          await http.get(Uri.parse("$url/user/info/$userId"), headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        realUserInfo = UserInfo.fromJson(responseBody);
        setState(() {});
      } else {
        if (!mounted) return;
        Future.microtask(() => showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  content: const Text(" 오류가 발생했습니다."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("닫기"),
                      onPressed: () {
                        navigatorKey.currentState?.pop();
                      },
                    ),
                  ],
                );
              },
            ));
      }
    } catch (e) {
      if (!mounted) return;
      Future.microtask(() => showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("그룹페이지 api(그룹정보)오류"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () {
                      navigatorKey.currentState?.pop();
                    },
                  ),
                ],
              );
            },
          ));
    }
  }

  putUserLocation() async {
    Map<String, String> header = {
      "accept": "*/*",
      "Authorization": "Bearer ${userInfo["accessToken"]}",
      "Content-Type": "application/json",
    };

    Map<String, double> param = {
      'latitude': userPosition.latitude,
      'longitude': userPosition.longitude
    };

    final response = await http.put(Uri.parse("$url/location"),
        headers: header, body: jsonEncode(param));
    print(response);
    if (response.statusCode == 200) {
      print('성공');
    } else {
      print('실패');
    }
  }

  getGuideLocation() async {
    try {
      Map<String, String> header = {
        "accept": "*/*",
        "Authorization": "Bearer ${userInfo["accessToken"]}",
        "Content-Type": "application/json",
      };

      final response = await http.get(Uri.parse("$url/location/guide/$groupId"),
          headers: header);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        realLocationInfo = LocationInfo.fromJson(responseBody);
        setState(() {});
      } else {
        if (!mounted) return;
        navigatorKey.currentState?.pop();
      }
    } catch (e) {
      if (!mounted) return;
      Future.microtask(() => showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: const Text("그룹페이지 api(그룹정보)오류"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () {
                      navigatorKey.currentState?.pop();
                    },
                  ),
                ],
              );
            },
          ));
    }
  }
}
