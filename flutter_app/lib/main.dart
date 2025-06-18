import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(PharmaLocatorApp());
}

class PharmaLocatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaLocator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
