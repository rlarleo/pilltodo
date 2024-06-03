import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/lib/state/time.dart';

class Device {
  String? deviceId;

  Device({this.deviceId});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(deviceId: json['deviceId']);
  }
}

class User {
  String? name;
  String? gender;
  User({required this.name, required this.gender});
}

class FirebaseTime {
  final int hour;
  final int minute;

  FirebaseTime({required this.hour, required this.minute});

  // FirebaseTime 객체를 Map<String, dynamic>으로 변환하는 함수
  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  // Map<String, dynamic>을 FirebaseTime 객체로 변환하는 함수
  factory FirebaseTime.fromMap(Map<String, dynamic> map) {
    return FirebaseTime(
      hour: map['hour'] as int,
      minute: map['minute'] as int,
    );
  }
}

// FirebaseTime 객체 리스트를 Map 리스트로 변환하는 함수
List<Map<String, dynamic>> timesToMapList(List<Time> times) {
  return times.map((time) => timeToFirebaseTime(time).toMap()).toList();
}

FirebaseTime timeToFirebaseTime(Time time) {
  return FirebaseTime(
    hour: time.hour,
    minute: time.minute,
  );
}

// Map 리스트를 FirebaseTime 객체 리스트로 변환하는 함수
List<FirebaseTime> mapListToTimes(List<Map<String, dynamic>> mapList) {
  return mapList.map((map) => FirebaseTime.fromMap(map)).toList();
}

class DateTimeCheck {
  bool checked;
  final DateTime dateTime;
  late String name;

  DateTimeCheck({required this.checked, required this.dateTime});

  factory DateTimeCheck.fromMap(Map<String, dynamic> map) {
    return DateTimeCheck(
      checked: map['checked'] as bool,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checked': checked,
      'dateTime': dateTime,
    };
  }
}

class Pill {
  final String name;
  final List<DateTimeCheck> dateTimes;
  final DateTime startDate;
  final DateTime endDate;
  final List<bool> selectedDays;
  final List<Time> times;

  Pill({
    required this.name,
    required this.dateTimes,
    required this.startDate,
    required this.endDate,
    required this.selectedDays,
    required this.times,
  });

  factory Pill.fromMap(Map<String, dynamic> map) {
    return Pill(
      name: map['name'] as String,
      dateTimes: (map['dateTimes'] as List)
          .map((dt) => DateTimeCheck.fromMap(dt as Map<String, dynamic>))
          .toList(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      selectedDays: (map['selectedDays'].cast<bool>() ??
          [
            true,
            true,
            true,
            true,
            true,
            true,
            true,
          ]),
      times: (map['times'] as List)
          .map((dt) => Time(hour: dt['hour'], minute: dt['minute']))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateTimes': dateTimes.map((dt) => dt.toMap()).toList(),
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
