import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:inteligencia_agro/View/tela-login/tela-login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(DevicePreview(
    enabled: true, 
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inteligência Agro',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage() 
    );
  }
}


