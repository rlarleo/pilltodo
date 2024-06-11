import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:pilltodo/screens/test_screen.dart';
import 'package:pilltodo/widgets/pill_input.dart';
import 'package:provider/provider.dart';

class ExampleCard extends StatefulWidget {
  final Pill pill;
  final Future<void> Function() onRefresh;

  const ExampleCard({
    super.key,
    required this.pill,
    required this.onRefresh,
  });

  @override
  State<ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<ExampleCard> {
  bool _isNext = false;

  Future<void> _deletePillsForUser(String? deviceId, String? name) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference userRef = firestore.collection('user').doc(deviceId);
      DocumentSnapshot userSnapshot = await userRef.get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        if (userData.containsKey('pills')) {
          List<dynamic> pills = userData['pills'];

          pills.removeWhere((pill) {
            return pill is Map<String, dynamic> && pill['name'] == name;
          });

          await userRef.update({'pills': pills});
        }
      }

      // 사용자 문서 업데이트
    } catch (e) {
      // 오류 처리
      print('Error updating pills for user: $e');
    }
  }

  Future<void> _deleteData(deviceId, name) async {
    await _deletePillsForUser(deviceId, name);
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    String? deviceId = Provider.of<DeviceProvider>(context).deviceId;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(216, 0, 0, 0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                // gradient: candidate.color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pill.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.pill.startDate.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.pill.startDate.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    Row(children: [
                      ElevatedButton(
                        onPressed: () => {
                          AwesomeDialog(
                            context: context,
                            animType: AnimType.scale,
                            headerAnimationLoop: false,
                            dialogType: DialogType.success,
                            showCloseIcon: true,
                            body: PillInputForm(
                              isNext: _isNext,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _isNext = newValue;
                                });
                              },
                              onRefresh: widget.onRefresh,
                              deviceId: deviceId,
                              pill: widget.pill,
                              inputType: 'Modify',
                            ),
                            onDismissCallback: (type) {
                              _isNext = false;
                              debugPrint('Dialog Dismiss from callback $type');
                            },
                          ).show()
                        },
                        child: const Text('수정'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _deleteData(deviceId, widget.pill.name),
                        child: const Text('삭제'),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
