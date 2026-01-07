import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'motioncore_foreground',
    'MotionCore Service',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'motioncore_foreground',
      initialNotificationTitle: 'MotionCore Active',
      initialNotificationContent: 'Terraforming in progress...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  try {
    Pedometer.stepCountStream.listen((StepCount event) async {
      flutterLocalNotificationsPlugin.show(
        888,
        'MotionCore Active',
        'Steps: ${event.steps}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'motioncore_foreground',
            'MotionCore Service',
            icon: '@mipmap/ic_launcher',
            ongoing: true,
          ),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('motioncore_steps', event.steps);
      
      service.invoke(
        'update',
        {
          "steps": event.steps,
        },
      );
    });
  } catch (e) {
    print('Background service sensor error: $e');
  }
}
