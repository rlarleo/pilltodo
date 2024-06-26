import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;

  Future<void> _updateUserData(String? deviceId) async {
    await FirebaseFirestore.instance.collection('user').doc(deviceId).update({
      'name': _nameController.text,
      'gender': _selectedGender,
      'timestamp': DateTime.now(),
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')));
  }

  @override
  Widget build(BuildContext context) {
    String? deviceId = Provider.of<DeviceProvider>(context).deviceId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '이름을 입력해주세요.',
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Radio<String>(
                    value: '형아',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const Text('Male'),
                  Radio<String>(
                    value: '누나',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const Text('Female'),
                ],
              ),
              ElevatedButton(
                onPressed: () => _updateUserData(deviceId),
                child: const Text('수정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
