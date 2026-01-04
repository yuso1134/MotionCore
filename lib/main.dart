import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // İzin kütüphanesi
import 'providers/motion_core_provider.dart';
import 'services/sensor_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter engine'i hazırla
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

class _MotionCoreHomeState extends State<MotionCoreHome> {
  SensorService? _sensorService;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    // initState'te context'e erişmek için addPostFrameCallback kullanılır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSensors();
    });
  }

  Future<void> _initializeSensors() async {
    if (_isInit) return;
    _isInit = true;

    // 1. İzinleri kontrol et ve iste
    bool granted = await _requestPermissions();
    if (!granted) {
      debugPrint("Physical Activity permission denied!");
      // İzin verilmezse kullanıcıya uyarı gösterilebilir veya demo modu açılabilir
      return;
    }

    // 2. Provider'a erişim (listen: false olmalı çünkü sadece metot çağırıyoruz)
    final provider = Provider.of<MotionCoreProvider>(context, listen: false);
    _sensorService = SensorService(provider);
    
    try {
      // 3. İlk adım sayısını al
      final initialSteps = await _sensorService!.getInitialStepCount();
      if (initialSteps > 0) {
        provider.updateSteps(initialSteps);
      }
      
      // 4. Sensor stream'lerini başlat
      await _sensorService!.startListening();
    } catch (e) {
      // Sensor erişimi yoksa veya hata varsa, logla
      debugPrint('Sensor initialization failed: $e');
    }
  }

  // İzin isteme fonksiyonu
  Future<bool> _requestPermissions() async {
    // Android 10 (API 29) ve üzeri için ACTIVITY_RECOGNITION izni gerekir
    final status = await Permission.activityRecognition.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Kullanıcı reddetti, tekrar iste
      return false;
    } else if (status.isPermanentlyDenied) {
      // Kullanıcı kalıcı olarak reddetti, ayarlara yönlendir
      openAppSettings();
      return false;
    }
    return false;
  }

  @override
  void dispose() {
    _sensorService?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      child: const DashboardScreen(),
    );
  }
}
