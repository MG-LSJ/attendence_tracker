import 'package:attendance_tracker/permissions.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendence App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Mark Attendence',
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
            width: double.infinity,
          ),
          FilledButton(
            onPressed: () async {
              if (await isBluetoothOn(context, '/'))
                Navigator.pushNamed(context, '/peripheral');
            },
            child: const Text('Student'),
          ),
          const SizedBox(
            height: 20,
            width: double.infinity,
          ),
          FilledButton(
            onPressed: () async {
              if (await isBluetoothOn(context, '/'))
                Navigator.pushNamed(context, '/central');
            },
            child: const Text('Teacher'),
          ),
        ],
      ),
    );
  }
}
