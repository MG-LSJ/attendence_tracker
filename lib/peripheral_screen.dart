import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_ble_peripheral_central/flutter_ble_peripheral_central.dart';

int stdId = 123456;

class PeripheralScreen extends StatefulWidget {
  const PeripheralScreen({super.key});

  @override
  State<PeripheralScreen> createState() => _PeripheralScreenState();
}

class _PeripheralScreenState extends State<PeripheralScreen> {
  final _flutterBlePeripheralCentralPlugin = FlutterBlePeripheralCentral();

  List<String> _events = [];
  final _eventStreamController = StreamController<String>();
  final _readableText = TextEditingController();
  final _bluetoothState = TextEditingController();

  bool _isSwitchOn = false;
  final ScrollController _scrollController = ScrollController();

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  void dispose() {
    _eventStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peripheral')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Turn On/Off"),
              Switch(
                value: _isSwitchOn,
                onChanged: (value) {
                  setState(() {
                    _isSwitchOn = value;
                  });

                  if (_isSwitchOn) {
                    _bleStartAdvertising();
                  } else {
                    _bleStopAdvertising();
                  }
                },
              ),
              SizedBox(
                height: 20,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Student ID",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.55,
                              height: 45,
                              child: TextField(
                                controller: _readableText
                                  ..text = stdId.toString(),
                                decoration: const InputDecoration(
                                  // hintText: 'Input indicate value',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () async {
                                  stdId = int.parse(_readableText.text);
                                  _bleEditTextCharForRead(_readableText.text);
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
                width: double.infinity,
              ),
              Text("Debug Log"),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                child: Container(
                  width: double.infinity,
                  // height: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(
                        _events[index],
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamSubscription<dynamic>? _eventSubscription;

  void _bleStartAdvertising() async {
    _clearLog();
    _eventStreamController.sink.add('Starting...');

    _eventSubscription = _flutterBlePeripheralCentralPlugin
        .startBlePeripheralService("", "")
        .listen(
      (event) {
        _eventStreamController.sink.add('-> ' + event);

        _addEvent(event);

        print('----------------------->event: ' + event);
      },
    );
    _bleEditTextCharForRead(stdId.toString());
  }

  void _bleEditTextCharForRead(String id) async {
    await _flutterBlePeripheralCentralPlugin.editTextCharForRead("STD_ID:$id");
  }

  void _bleStopAdvertising() async {
    await _flutterBlePeripheralCentralPlugin.stopBlePeripheralService();
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
        _bluetoothState.text = responseMap['state'];
      });

      if (event == 'disconnected') {
        _eventSubscription?.cancel();
      }
    } else if (responseMap.containsKey('onCharacteristicWriteRequest')) {
      writeHandler(responseMap['onCharacteristicWriteRequest']);
    } else {
      print('Message key not found in the JSON response.');
    }

    // Scroll to the end of the list
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void writeHandler(String value) {
    print('writeHandler: $value');
    if (value == "OK") {
      _bleStopAdvertising();
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Attendence Marked'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your attendence has been marked successfully'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      );
    }
  }

  // clear the log
  void _clearLog() {
    setState(() {
      _events.clear();
    });
  }
}
