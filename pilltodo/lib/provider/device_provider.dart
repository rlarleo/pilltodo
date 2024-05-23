import 'package:flutter/material.dart';

class DeviceProvider extends ChangeNotifier {
  String? _deviceId;

  String? get deviceId => _deviceId;

  set deviceId(String? value) {
    _deviceId = value;
    notifyListeners();
  }
}
