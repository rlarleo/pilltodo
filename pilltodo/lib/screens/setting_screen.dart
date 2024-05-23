import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey,
        child: const Center(child: Text('성별, 이름, 알림 발생 여부')));
  }
}
