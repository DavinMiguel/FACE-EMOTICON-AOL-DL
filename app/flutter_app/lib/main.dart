import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(PersonalityScannerApp());
}

class PersonalityScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personality Scanner',
      theme: ThemeData(
        primarySwatch: Colors.pink,  // Magenta/pink
        primaryColor: Color(0xFFE91E63),  // Magenta pink
        colorScheme: ColorScheme.light(
          primary: Color(0xFFE91E63),  // Magenta
          secondary: Color(0xFF9C27B0),  // Purple
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFE91E63),  // Magenta
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}