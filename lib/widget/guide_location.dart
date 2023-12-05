import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travelsync_client_new/logo/airplaneLogo.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:travelsync_client_new/widgets/header.dart';

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

  Future<void> _updateMarkers() async {
    // 사용자의 현재 위치를 가져오기
    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    // 서버에서 특정 위치를 가져오기 (가상의 예제 위치)
    Position serverPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    // 마커 설정
    Marker userMarker = Marker(
      markerId: const MarkerId('userMarker'),
      position: LatLng(userPosition.latitude, userPosition.longitude),
      infoWindow: const InfoWindow(
        title: '현 위치',
        snippet: '랙릉린님',
      ),
    );

    Marker serverMarker = Marker(
      markerId: const MarkerId('serverMarker'),
      position: LatLng(serverPosition.latitude, serverPosition.longitude),
      infoWindow: const InfoWindow(title: '가이드 위치'),
    );

    // 마커 갱신
    setState(() {
      _markers.clear();
      _markers.add(userMarker);
      _markers.add(serverMarker);
    });

    // 지도를 사용자의 위치로 이동
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(userPosition.latitude, userPosition.longitude)));
  }

  @override
  void initState() {
    super.initState();

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
              navigatorKey.currentState?.pop();
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
