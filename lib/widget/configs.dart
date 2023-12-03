import 'package:flutter_background_service/flutter_background_service.dart';

class AndroidConfiguration {
  /// must be a top level or static method
  final Function(ServiceInstance service) onStart;

  /// whether service can start automatically after configure
  final bool autoStart;

  /// whether service can start automatically on boot
  final bool autoStartOnBoot;

  /// whether serivce is foreground or background mode
  final bool isForegroundMode;

  /// notification content that will be shown on status bar when the background service is starting
  /// defaults to "Preparing"
  final String initialNotificationContent;
  final String initialNotificationTitle;

  ///use custom notification channel id
  ///you must to create the notification channel before you run configure() method.
  final String? notificationChannelId;

  /// notification id will be used by foreground service
  final int foregroundServiceNotificationId;

  AndroidConfiguration({
    required this.onStart,
    this.autoStart = true,
    this.autoStartOnBoot = true,
    required this.isForegroundMode,
    this.initialNotificationContent = 'Preparing',
    this.initialNotificationTitle = 'Background Service',
    this.notificationChannelId,
    this.foregroundServiceNotificationId = 112233,
  });
}
