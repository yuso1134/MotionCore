import 'dart:async';
import 'dart:ui'; // DartPluginRegistrant için gerekli
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Servisi başlatma fonksiyonu (main.dart'tan çağrılacak)
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Android bildirim kanalı ayarları
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'motioncore_foreground', // id
    'MotionCore Service', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.low, // low importance to prevent sound
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // Servis başlangıcında çalışacak fonksiyon (top-level olmalı)
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

// iOS için background fonksiyonu
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// Servis başladığında çalışacak ana fonksiyon
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Dart Plugin kaydı (gerekirse)
  DartPluginRegistrant.ensureInitialized();
  
  // Bildirim eklentisi
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Shared Preferences (veri kaydı için)
  // Not: Arkaplan izole bir thread'de çalıştığı için Provider'a doğrudan erişemeyiz.
  // Bu yüzden SharedPreferences ile basit bir kayıt mekanizması kullanacağız
  // veya sadece sensor dinleyip kaydedeceğiz.
  
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Pedometer dinleme
  try {
    // Adım sayısı akışı
    Pedometer.stepCountStream.listen((StepCount event) async {
      // 1. Bildirimi güncelle
      flutterLocalNotificationsPlugin.show(
        888,
        'MotionCore Active',
        'Steps: ${event.steps}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'motioncore_foreground',
            'MotionCore Service',
            icon: '@mipmap/ic_launcher', // İkon düzeltildi
            ongoing: true,
          ),
        ),
      );

      // 2. Veriyi kaydet (SharedPreferences)
      // Bu kısım ana uygulama ile senkronize olmalı
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('motioncore_steps', event.steps);
      
      // Servis üzerinden UI'a veri gönder (uygulama açıksa)
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
