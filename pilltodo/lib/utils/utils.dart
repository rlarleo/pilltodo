// utils.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<String> checkAndInsertData() async {
  String deviceId = await getDeviceUniqueId();
  print(deviceId);
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // 해당 deviceId가 존재하는지 확인
    var querySnapshot = await firestore
        .collection('user')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // 존재하지 않으면 새 데이터 추가
      await firestore.collection('user').doc(deviceId).set({
        'deviceId': deviceId,
        'timestamp': DateTime.now(),
        'gender': null,
        'name': null,
        'pills': null,
      });
      print('Data inserted successfully!');
    } else {
      print('Device ID already exists.');
    }
  } catch (e) {
    print('Error checking or inserting data: $e');
  }
  return deviceId;
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
