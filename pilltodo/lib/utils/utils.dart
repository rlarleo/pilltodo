// utils.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:provider/provider.dart';

Future<List<Pill>> getPills(BuildContext context) async {
  String? deviceId = Provider.of<DeviceProvider>(context).deviceId;
  if (deviceId != null) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('user').doc(deviceId);
    DocumentSnapshot userSnapshot = await userRef.get();

    // 기존 pills 데이터 가져오기
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    if (userData != null &&
        userData.containsKey('pills') &&
        userData['pills'] is List<dynamic>) {
      List<dynamic> pillDataList = userData['pills'];
      List<Pill> result = [];

      for (var pillData in pillDataList) {
        var pill = Pill.fromMap(pillData as Map<String, dynamic>);
        result.add(pill);
      }
      return result;
    }
  }
  return [];
}

Future<List<DateTimeCheck>> getAlarms(BuildContext context) async {
  String? deviceId = Provider.of<DeviceProvider>(context).deviceId;
  if (deviceId != null) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('user').doc(deviceId);
    DocumentSnapshot userSnapshot = await userRef.get();

    // 기존 pills 데이터 가져오기
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    if (userData != null &&
        userData.containsKey('pills') &&
        userData['pills'] is List<dynamic>) {
      List<dynamic> pillDataList = userData['pills'];
      List<DateTimeCheck> allDateTimeChecks = [];

      // 캘린더의 데이터가 보여야함
      DateTime today = DateTime.now();

      DateTime todayStart = DateTime(today.year, today.month, today.day);
      DateTime todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      for (var pillData in pillDataList) {
        var pill = Pill.fromMap(pillData as Map<String, dynamic>);
        if (today.isAfter(pill.startDate) && today.isBefore(pill.endDate)) {
          for (var dateTimeCheck in pill.dateTimes) {
            if (dateTimeCheck.dateTime.isAfter(todayStart) &&
                dateTimeCheck.dateTime.isBefore(todayEnd)) {
              dateTimeCheck.name = pill.name;
              allDateTimeChecks.add(dateTimeCheck);
            }
          }
        }
      }
      return allDateTimeChecks;
    }
  }
  return [];
}

Future<void> checkAndInsertData(BuildContext context) async {
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
  // Provider.of<DeviceProvider>(context, listen: false).deviceId = deviceId;

  final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
  deviceProvider.deviceId = deviceId;
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

void handleOkButtonPress() {
  debugPrint('OnClick');
}

IconData? getOkButtonIcon(bool isNext) {
  return isNext ? Icons.check_circle : null;
}

VoidCallback? getOkButtonPressHandler(bool isNext) {
  return isNext ? handleOkButtonPress : null;
}
