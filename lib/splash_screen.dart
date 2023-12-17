import 'package:attendance_tracker/permissions.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _permissions();
  }

  Future<void> _permissions() async {
    if (await permissionCheck() && await isBluetoothOn(context, '/splash')) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/splash', (route) => false);
    }
  }
}
