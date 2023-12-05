import 'package:flutter/material.dart';
import 'package:travelsync_client_new/widget/app_start.dart';
import 'package:travelsync_client_new/widget/testapi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initLocationState();
  runApp(const AppStart());
}
