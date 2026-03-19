import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'di/data_layer.dart';
import 'screens/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the data layer first (critical for app to work)
  await DataLayer.initialize();

  // Initialize Google Mobile Ads (non-blocking - continue even if it fails)
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    // Continue anyway - ads are not critical
    debugPrint('Mobile Ads initialization failed: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const SpaceDodgerApp());
}

class SpaceDodgerApp extends StatelessWidget {
  const SpaceDodgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Dodger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
