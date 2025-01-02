//992024008 - Nurmei Sarrah
//162022037 - Jamilah Kamaliah
//162022035 - Muhammad Thoriq Aziz
//162022042 - Nail Ghani Prihartono
//162022055 - Muhammad Ghafiki Putra

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'landing_page.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const SeekJobApp(),
    ),
  );
}

class SeekJobApp extends StatelessWidget {
  const SeekJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false);
  }
}
