import 'package:flutter/material.dart';

import 'features/capture/presentation/capture_screen.dart';

class DeclutterAIApp extends StatelessWidget {
  const DeclutterAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DECLuTTER AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5D63FF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CaptureScreen(),
    );
  }
}
