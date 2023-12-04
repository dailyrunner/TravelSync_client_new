import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travelsync_client_new/models/plan.dart';
import 'package:travelsync_client_new/models/tour.dart';
import '../tour/emptyTour.dart';

class TourListView extends StatefulWidget {
  const TourListView({super.key});
  static const storage = FlutterSecureStorage();
  @override
  State<TourListView> createState() => _TourListViewState();
}

class _TourListViewState extends State<TourListView> {
  late Tour tour;
  late Plan plan;

  /*    *    *    *    *    *    *    *    *    */
  late String url;
  // FlutterSecureStorage를 storage로 저장
  dynamic userInfo = '';
  // storage에 있는 유저 정보를 저장
  @override
  void initState() {
    super.initState();
    // 비동기로 flutter secure storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    userInfo = await TourListView.storage.read(key: 'login');
    url = (await TourListView.storage.read(key: 'address'))!;
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (userInfo == null) {
      Navigator.pushNamed(context, '/');
    }
  }
/*    *    *    *    *    *    *    *    *    */

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: NoTourMessage(),
        ),
      ],
    );
  }
}
