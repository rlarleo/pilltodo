// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:pilltodo/screens/first_screen.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

final DateFormat dateFormat = DateFormat('yyyy.MM.dd');

Future<User?> getUser(BuildContext context) async {
  String? deviceId =
      Provider.of<DeviceProvider>(context, listen: false).deviceId;
  if (deviceId != null) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('user').doc(deviceId);
    DocumentSnapshot userSnapshot = await userRef.get();

    // 기존 pills 데이터 가져오기
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    return User(name: userData?["name"], gender: userData?["gender"]);
  }
  return null;
}

Future<List<Pill>> getPills(BuildContext context) async {
  String? deviceId =
      Provider.of<DeviceProvider>(context, listen: false).deviceId;
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

Future<List<DateTimeCheck>> getAlarms(
    String? deviceId, DateTime selectedDate) async {
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
      DateTime today = selectedDate.add(const Duration(seconds: 1));
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
  final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
  deviceProvider.deviceId = deviceId;
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // 해당 deviceId가 존재하는지 확인
    var querySnapshot = await firestore
        .collection('user')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const FirstScreen(),
        ),
      );
    } else {
      print('Device ID already exists.');
    }
  } catch (e) {
    print('Error checking or inserting data: $e');
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

int compareTime(Time a, Time b) {
  if (a.hour < b.hour) {
    return -1;
  } else if (a.hour > b.hour) {
    return 1;
  } else {
    if (a.minute < b.minute) {
      return -1;
    } else if (a.minute > b.minute) {
      return 1;
    } else {
      return 0;
    }
  }
}

void showToast(BuildContext context, ToastificationType type, String title) {
  toastification.show(
    context: context,
    type: type, //
    style: ToastificationStyle
        .flatColored, // flat, fillColored, flatColored, minimal
    title: Text(title),
    // description: RichText(text: TextSpan(text: description)),
    alignment: Alignment.topLeft,

    autoCloseDuration: const Duration(seconds: 3),
  );
}
