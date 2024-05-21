import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('귀남이!'),
          backgroundColor: Colors.brown,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _insertData();
            },
            child: Text('Insert Data to Firestore'),
          ),
        ),
      ),
    );
  }

  Future<void> _insertData() async {
    try {
      // Firestore 인스턴스 가져오기
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 데이터 추가
      await firestore.collection('user').add({
        'deviceId': await getDeviceUniqueId(),
        'timestamp': DateTime.now(),
      });

      print('Data inserted successfully!');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<String> getDeviceUniqueId() async {
    var deviceIdentifier = 'unknown';

    var deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;
      deviceIdentifier = webInfo.vendor! +
          webInfo.userAgent! +
          webInfo.hardwareConcurrency.toString();
    } else if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      // 불안..
      deviceIdentifier = androidInfo.id;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceIdentifier = iosInfo.identifierForVendor!;
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId!;
    }

    return deviceIdentifier;
  }
}
