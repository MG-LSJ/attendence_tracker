import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_ble_peripheral_central/flutter_ble_peripheral_central.dart';
import 'package:permission_handler/permission_handler.dart';

class CentralScreen extends StatefulWidget {
  const CentralScreen({super.key});

  @override
  State<CentralScreen> createState() => _CentralScreenState();
}

class _CentralScreenState extends State<CentralScreen> {
  final _flutterBlePeripheralCentralPlugin = FlutterBlePeripheralCentral();

  final List<String> _events = [];
  final List<String> _detectedIds = [];
  final _eventStreamController = StreamController<String>();

  final _lifecycleState = TextEditingController();

  bool _isSwitchOn = false;

  final ScrollController _debugScrollController = ScrollController();
  final ScrollController _idScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _permissionCheck();
  }

  @override
  void dispose() {
    _eventStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Lifecycle State",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 45,
                  child: TextField(
                    controller: _lifecycleState,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    enabled: false,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
                width: double.infinity,
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 45,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Text(
                          'Scan & autoconnect',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.17,
                      height: 45,
                      child: Transform.scale(
                        scale: 1.3,
                        child: Switch(
                          value: _isSwitchOn,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _isSwitchOn = value;
                            });

                            if (_isSwitchOn) {
                              _bleScanAndConnect();
                            } else {
                              _bleDisconnect();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
                width: double.infinity,
              ),
              Text("Detected id"),
              Container(
                width: double.infinity,
                // height: double.infinity,
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ListView.builder(
                  controller: _idScrollController,
                  itemCount: _detectedIds.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _detectedIds[index],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 25,
                width: double.infinity,
              ),
              Text("Debug Log"),
              Container(
                width: double.infinity,
                // height: double.infinity,
                height: MediaQuery.of(context).size.height * 0.32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ListView.builder(
                  controller: _debugScrollController,
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _events[index],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleConnect() async {
    String? result = await _bleReadCharacteristic();
    print('result: $result');
    if (result != null) {
      String id = result.split(":")[1];
      print('id: $id');
      if (!_detectedIds.contains(id)) {
        setState(() {
          _detectedIds.add(id);
        });
      }
      _bleWriteCharacteristic("OK");
      _bleDisconnect();
      _bleScanAndConnect();
    }
  }

  StreamSubscription<dynamic>? _eventSubscription;
  void _bleScanAndConnect() async {
    _clearLog();
    _eventStreamController.sink.add('Starting...');

    _eventSubscription = await _flutterBlePeripheralCentralPlugin
        .scanAndConnect()
        .listen((event) {
      _eventStreamController.sink.add('-> ' + event);

      _addEvent(event);

      print('----------------------->event: ' + event);
    });
  }

  Future<String?> _bleReadCharacteristic() async {
    return await _flutterBlePeripheralCentralPlugin.bleReadCharacteristic();
  }

  void _bleWriteCharacteristic(String sendData) async {
    await _flutterBlePeripheralCentralPlugin.bleWriteCharacteristic(sendData);
  }

  void _bleDisconnect() async {
    await _flutterBlePeripheralCentralPlugin.bleDisconnect();
  }

  // add the event
  void _addEvent(String event) {
    setState(() {
      _events.add(event);
    });

    Map<String, dynamic> responseMap = jsonDecode(event);

    if (responseMap.containsKey('message')) {
      String message = responseMap['message'];
      print('Message: $message');
    } else if (responseMap.containsKey('state')) {
      setState(() {
        _lifecycleState.text = responseMap['state'];
        if (responseMap['state'] == 'connected') {
          _handleConnect();
        }
      });
      if (event == 'disconnected') {
        _eventSubscription?.cancel();
      }
    } else if (responseMap.containsKey('onCharacteristicChanged')) {
    } else {
      print('Message key not found in the JSON response.');
    }

    // Scroll to the end of the list
    _debugScrollController
        .jumpTo(_debugScrollController.position.maxScrollExtent);
  }

  // clear the log
  void _clearLog() {
    setState(() {
      _events.clear();
    });
  }

  void _permissionCheck() async {
    if (Platform.isAndroid) {
      var permission = await Permission.location.request();
      var bleScan = await Permission.bluetoothScan.request();
      var bleConnect = await Permission.bluetoothConnect.request();
      var bleAdvertise = await Permission.bluetoothAdvertise.request();
      var locationWhenInUse = await Permission.locationWhenInUse.request();

      print('location permission: ${permission.isGranted}');
      print('bleScan permission: ${bleScan.isGranted}');
      print('bleConnect permission: ${bleConnect.isGranted}');
      print('bleAdvertise permission: ${bleAdvertise.isGranted}');
      print('location locationWhenInUse: ${locationWhenInUse.isGranted}');
    }
  }
}
