import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; 
import 'providers/motion_core_provider.dart';
import 'services/sensor_service.dart';
import 'services/background_service.dart'; // Arkaplan servisi
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MotionCoreApp());
}

class MotionCoreApp extends StatelessWidget {
  const MotionCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MotionCoreProvider(),
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

class _MotionCoreHomeState extends State<MotionCoreHome> with WidgetsBindingObserver {
  SensorService? _sensorService;
  bool _isLoading = true; // Splash ekranı için gerekli

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // UI çizildikten hemen sonra sensörleri başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAppInitialization();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        final provider = Provider.of<MotionCoreProvider>(context, listen: false);
        provider.initialize();
      }
    }
  }

  Future<void> _startAppInitialization() async {
    // Splash ekranının en az 3 saniye görünmesini sağla
    final minSplashDuration = Future.delayed(const Duration(seconds: 3));
    
    // Başlatma işlemlerini yap
    final initProcess = _initializeSensors();
    
    // İkisini de bekle
    await Future.wait([minSplashDuration, initProcess]);
    
    // Bittiğinde Splash'i kaldır
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeSensors() async {
    try {
      await _requestPermissions();
      
      try {
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      } catch (_) {}

      try {
        await initializeService();
      } catch (e) {
        debugPrint("Bg service error (Ignored): $e");
      }

      if (mounted) {
        final provider = Provider.of<MotionCoreProvider>(context, listen: false);
        await provider.initialize();

        _sensorService = SensorService(provider);
        
        try {
          final initialSteps = await _sensorService!.getInitialStepCount().timeout(
            const Duration(seconds: 2), 
            onTimeout: () => 0
          );
          
          if (initialSteps > 0) {
            provider.updateSteps(initialSteps);
          }
          await _sensorService!.startListening();
        } catch (e) {
          debugPrint('Sensor error (Ignored): $e');
        }
      }
    } catch (e) {
      debugPrint("Init error: $e");
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sensorService?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _isLoading true ise Splash, false ise Dashboard göster
    if (_isLoading) {
      return const SplashScreen(); // child parametresi kaldırıldı
    }
    
    return const DashboardScreen();
  }
}
