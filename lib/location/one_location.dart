import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travelsync_client_new/location/people_check.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';

class OneLocation extends StatefulWidget {
  const OneLocation({super.key});

  @override
  State<OneLocation> createState() => OneLocationState();
}

//처음 켤 때 사용자 위치 지정하는 함수, 사용자 현재 위치로 구현하고자 한다.
class OneLocationState extends State<OneLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  late Position userPosition;
  late Timer _updateTimer;

  late String url;

  static const storage =
      FlutterSecureStorage(); // FlutterSecureStorage를 storage로 저장
  dynamic userKey = ''; // storage에 있는 유저 정보를 저장
  dynamic userInfo = '';
  dynamic groupId = '';
  String lati = '';
  double latitude = 0;
  String long = '';
  double longitude = 0;

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userKey = await storage.read(key: 'login');
    url = (await storage.read(key: 'address'))!;
    groupId = await storage.read(key: 'groupId');
    lati = (await storage.read(key: 'latitude'))!;
    latitude = double.parse(lati);
    long = (await storage.read(key: 'longitude'))!;
    longitude = double.parse(long);

    // user의 정보가 없다면 로그인 페이지로 넘어가게 합니다.
    if (userKey == null) {
      navigatorKey.currentState?.pushNamed('/');
    } else {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    // 마커 설정
    Marker userMarker = Marker(
      markerId: const MarkerId('userMarker'),
      position: LatLng(
        latitude,
        longitude,
      ),
    );

    // 마커 갱신
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.add(userMarker);
      });
    }

    // 지도를 사용자의 위치로 이동
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          latitude,
          longitude,
        ),
      ),
    );
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
              storage.delete(key: 'latitude');
              storage.delete(key: 'longitude');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PeopleCheck(),
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
}
