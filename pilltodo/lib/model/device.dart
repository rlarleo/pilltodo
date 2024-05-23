class Device {
  String? deviceId;

  Device({this.deviceId});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(deviceId: json['deviceId']);
  }
}
