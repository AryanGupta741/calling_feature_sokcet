import 'package:calling_feature_socket_webrtc/socket_server.dart';
import 'package:flutter/material.dart';
// import 'socket_service.dart';
import 'webrtc_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? myID;
  String? targetID;
  SocketService? socketService;
  WebRTCService? webrtcService;

  @override
  void initState() {
    super.initState();
    socketService = SocketService();
    webrtcService = WebRTCService(socketService!);

    socketService!.connect();
    socketService!.onReceiveID((id) {
      setState(() {
        myID = id;
      });
    });

    // Listen for incoming calls
    socketService!.onCallMade((signal, from) {
      webrtcService!.createAnswer(signal, from);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Voice Call App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your ID: $myID'),
              TextField(
                decoration: InputDecoration(hintText: "Enter target ID"),
                onChanged: (value) {
                  targetID = value;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (targetID != null) {
                    webrtcService!.initiateCall(targetID!);
                  }
                },
                child: Text('Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
