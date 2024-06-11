import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pilltodo/utils/utils.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  Future<void> _onSubmit(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? deviceId = await getDeviceUniqueId();

    await firestore.collection('user').doc(deviceId).set({
      'deviceId': deviceId,
      'timestamp': DateTime.now(),
      'gender': _selectedGender,
      'name': _nameController.text,
      'pills': null,
    });
    Navigator.pop(context); // 현재 페이지를 닫기
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                '귀남이가 뭐라고 불러드릴까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 30),
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
              const SizedBox(height: 20.0),
              _selectedGender != null
                  ? Text('${_nameController.text} $_selectedGender 라고 부르면 될까요?')
                  : Container(),
              ElevatedButton(
                onPressed: () => _onSubmit(context),
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
