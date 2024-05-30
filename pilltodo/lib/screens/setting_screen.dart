import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:pilltodo/screens/first_screen.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future<void> _onSubmit(String? deviceId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(deviceId)
          .delete();
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => const FirstScreen(),
      //   ),
      // );
    } catch (e) {
      print('Error deleting user document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String? deviceId = Provider.of<DeviceProvider>(context).deviceId;

    return Scaffold(
      backgroundColor: Colors.brown,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100,
            horizontal: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _onSubmit(deviceId),
                child: const Text('초기화'),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
