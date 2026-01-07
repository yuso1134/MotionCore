import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // İzin kütüphanesi
import 'providers/motion_core_provider.dart';
import 'services/sensor_service.dart';
import 'services/background_service.dart'; // Arkaplan servisi
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter engine'i hazırla
  
  // Arkaplan servisini başlat (İzinler alındıktan sonra çalışacak ama init edelim)
  runApp(const MotionCoreApp());
}

class MotionCoreApp extends StatelessWidget {
  const MotionCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MotionCoreProvider(), // Constructor içinde initialize() var
      child: MaterialApp(
        title: 'MotionCore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF000510),
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            secondary: Colors.purpleAccent,
          ),
        ),
        home: const MotionCoreHome(),
      ),
    );
  }
}

class MotionCoreHome extends StatefulWidget {
  const MotionCoreHome({super.key});

  @override
  State<MotionCoreHome> createState() => _MotionCoreHomeState();
}

// WidgetsBindingObserver ekledik: Uygulama durumunu dinlemek için (Ön/Arka plan)
class _MotionCoreHomeState extends State<MotionCoreHome> with WidgetsBindingObserver {
  SensorService? _sensorService;
  bool _isInit = false;
  bool _isLoading = true; // Yüklenme durumunu takip et

  @override
  void initState() {
    super.initState();
    // Observer'ı kaydet
    WidgetsBinding.instance.addObserver(this);
    
    // UI çizildikten sonra sensörleri başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSensors();
    });
  }

  // Uygulama durumu değiştiğinde çalışır (Ön plana gelme vs.)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Uygulama tekrar ön plana geldiğinde (Resumed)
    if (state == AppLifecycleState.resumed) {
      // Verileri hafızadan tekrar yükle (Arkaplanda artmış olabilir)
      // mounted kontrolü ekledik
      if (mounted) {
        final provider = Provider.of<MotionCoreProvider>(context, listen: false);
        provider.initialize(); // Verileri yeniden yükle
      }
    }
  }

  Future<void> _initializeSensors() async {
    if (_isInit) return;
    _isInit = true;

    try {
      // 1. İzinleri kontrol et ve iste
      bool granted = await _requestPermissions();
      if (!granted) {
        debugPrint("Physical Activity permission denied!");
        // İzin verilmezse de uygulamayı aç, sadece sensör çalışmaz
      }
      
      // 1.1 Bildirim izinleri (Android 13+ için)
      // try-catch içine alarak hata olsa bile devam etmesini sağla
      try {
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      } catch (e) {
        debugPrint("Notification permission error: $e");
      }

      // 2. Arkaplan servisini başlat
      try {
        await initializeService();
      } catch (e) {
        debugPrint("Background service init error: $e");
      }

      // 3. Provider'a erişim (listen: false olmalı çünkü sadece metot çağırıyoruz)
      if (mounted) {
        final provider = Provider.of<MotionCoreProvider>(context, listen: false);
        _sensorService = SensorService(provider);
        
        try {
          // 4. İlk adım sayısını al
          final initialSteps = await _sensorService!.getInitialStepCount();
          if (initialSteps > 0) {
            provider.updateSteps(initialSteps);
          }
          
          // 5. Sensor stream'lerini başlat (Foreground'da dinlemek için)
          await _sensorService!.startListening();
        } catch (e) {
          // Sensor erişimi yoksa veya hata varsa, logla
          debugPrint('Sensor initialization failed: $e');
        }
      }
    } catch (e) {
      debugPrint("General initialization error: $e");
    } finally {
      // Her durumda yüklemeyi bitir ve dashboard'u göster
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // İzin isteme fonksiyonu
  Future<bool> _requestPermissions() async {
    try {
      // Android 10 (API 29) ve üzeri için ACTIVITY_RECOGNITION izni gerekir
      final status = await Permission.activityRecognition.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        // Kullanıcı reddetti, tekrar iste (opsiyonel)
        return false;
      } else if (status.isPermanentlyDenied) {
        // Kullanıcı kalıcı olarak reddetti
        // openAppSettings(); // Otomatik açmak kullanıcıyı rahatsız edebilir, sadece false dön
        return false;
      }
    } catch (e) {
      debugPrint("Permission request error: $e");
    }
    return false; // Hata durumunda veya izin yoksa false
  }

  @override
  void dispose() {
    // Observer'ı kaldır
    WidgetsBinding.instance.removeObserver(this);
    _sensorService?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Yükleniyor ise Splash, bitti ise Dashboard
    if (_isLoading) {
      return const SplashScreen(child: SizedBox()); // child boş olabilir, SplashScreen kendi içeriğini gösterir
    }
    return const DashboardScreen();
  }
}
