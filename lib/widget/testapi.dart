import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<void> initLocationState() async {
  int status = await BackgroundFetch.configure(
    BackgroundFetchConfig(
      // 최소 시간이 15분임
      minimumFetchInterval: 1,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
      requiredNetworkType: NetworkType.ANY,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      // 아래는 필요 없을 수도 있음
      requiresDeviceIdle: false,
    ),
    _onBackgroundFetch,
    _onBackgroundFetchTimeout,
  );
}

Future<Position> getLocation() async {
  var currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);
  return currentPosition;
}

void _onBackgroundFetch(String taskId) async {
  print("[BackgroundFetch] Event received $taskId");
  var currentLocation = await getLocation();
  print(currentLocation);

  const storage = FlutterSecureStorage();
  dynamic userKey = '';
  dynamic userInfo = '';

  userKey = await storage.read(key: 'login');
  String url = (await storage.read(key: 'address'))!;

  if (userKey != null) {
    userInfo = jsonDecode(userKey);
    Map<String, String> header = {
      "accept": "*/*",
      "Authorization": "Bearer ${userInfo["accessToken"]}",
      "Content-Type": "application/json",
    };

    Map<String, double> param = {
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude
    };

    print(param);

    final response = await http.put(Uri.parse("$url/location"),
        headers: header, body: jsonEncode(param));
    print(response);
    if (response.statusCode == 200) {
      print('성공');
    } else {
      print('실패');
    }
  }

  BackgroundFetch.finish(taskId);
}

void _onBackgroundFetchTimeout(String taskId) async {
  print("[BackgroundFetch] TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}
