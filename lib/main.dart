import 'package:attendance_tracker/central_screen.dart';
import 'package:attendance_tracker/home_screen.dart';
import 'package:attendance_tracker/peripheral_screen.dart';
import 'package:attendance_tracker/splash_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/': (context) => HomeScreen(),
            '/peripheral': (context) => PeripheralScreen(),
            '/central': (context) => CentralScreen(),
          },
          initialRoute: '/splash',
          title: 'Ble Student Backend',
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
