import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';

Future<void> initLocationState() async {
  int status = await BackgroundFetch.configure(
    BackgroundFetchConfig(
      // 최소 시간이 15분임
      minimumFetchInterval: 15,
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
  BackgroundFetch.finish(taskId);
}

void _onBackgroundFetchTimeout(String taskId) async {
  print("[BackgroundFetch] TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}
