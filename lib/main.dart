import 'package:flutter/material.dart';
import 'package:voice_assistant_felipe_silva/home_page.dart';
import 'package:voice_assistant_felipe_silva/palette.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Assistant',
      theme: ThemeData.light(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Palette.whiteColor,
          appBarTheme: const AppBarTheme(backgroundColor: Palette.whiteColor)),
      home: const HomePage(),
    );
  }
}
