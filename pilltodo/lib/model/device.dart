import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  String? deviceId;

  Device({this.deviceId});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(deviceId: json['deviceId']);
  }
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

  Pill({
    required this.name,
    required this.dateTimes,
    required this.startDate,
    required this.endDate,
  });

  factory Pill.fromMap(Map<String, dynamic> map) {
    return Pill(
      name: map['name'] as String,
      dateTimes: (map['dateTimes'] as List)
          .map((dt) => DateTimeCheck.fromMap(dt as Map<String, dynamic>))
          .toList(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
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
