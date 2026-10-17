import 'package:flutter/material.dart';

import '../core/theme/jaxx_theme.dart';
import '../features/home/home_screen.dart';

class JaxxApp extends StatelessWidget {
  const JaxxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JAXX AI',
      debugShowCheckedModeBanner: false,
      theme: JaxxTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
