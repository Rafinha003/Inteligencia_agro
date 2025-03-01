import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:inteligencia_agro/tela-inicial/tela-inicial.dart';

void main() {
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
      title: 'Hello word, bora Inteligência Agro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 223, 222, 224)),
      ),
      home: const TelaInicial() 
    );
  }
}


