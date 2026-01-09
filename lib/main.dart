import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/motion_core_provider.dart';
import 'services/sensor_service.dart';
import 'services/background_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() {
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);


    FlutterBackgroundService().on('update').listen((data) {
      if (data != null && data.containsKey('steps') && mounted) {
        final steps = data['steps'] as int;
        Provider.of<MotionCoreProvider>(context, listen: false).updateSteps(steps);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isInitialized) {
      if (mounted) {
        Provider.of<MotionCoreProvider>(context, listen: false).initialize();
      }
    }
  }

  Future<void> _initializeApp() async {
    try {
      final minSplashDuration = Future.delayed(const Duration(seconds: 3));
      final servicesInitialized = _initializeServices();

      await Future.wait([minSplashDuration, servicesInitialized]);
    } catch (e, stackTrace) {
      debugPrint("Error during app initialization: $e\n$stackTrace");
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _initializeServices() async {
    final provider = Provider.of<MotionCoreProvider>(context, listen: false);
    await provider.initialize();

    await [Permission.notification, Permission.activityRecognition].request();

    if (await Permission.activityRecognition.isGranted) {
      try {
        _sensorService = SensorService(provider);
        _sensorService!.startListening();
      } catch (e) {
        debugPrint("SensorService failed to initialize: $e");
      }
    }

    try {
      await initializeService();
    } catch (e) {
      debugPrint("BackgroundService failed to initialize: $e");
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
    return _isInitialized ? const DashboardScreen() : const SplashScreen();
  }
}
