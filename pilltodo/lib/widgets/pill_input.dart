// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pilltodo/icons/custom_icons.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/utils/utils.dart';
import 'package:pilltodo/widgets/button.dart';
import 'package:toastification/toastification.dart';

class PillInputForm extends StatefulWidget {
  final bool isNext;
  final ValueChanged<bool> onChanged;
  final String? deviceId;
  final Future<void> Function() onRefresh;
  final Pill? pill;
  final String inputType;

  const PillInputForm({
    super.key,
    required this.isNext,
    required this.onChanged,
    required this.deviceId,
    required this.onRefresh,
    required this.pill,
    required this.inputType,
  });

  @override
  State<PillInputForm> createState() => _PillInputFormState();
}

class _PillInputFormState extends State<PillInputForm> {
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isNext;
  final Time _time = Time(hour: 11, minute: 30);
  List<bool> _selectedDays = [true, true, true, true, true, true, true];
  List<Time> _times = [
    Time(hour: 9, minute: 00),
    Time(hour: 12, minute: 00),
    Time(hour: 18, minute: 00),
  ];
  bool iosStyle = true;

  TextEditingController _pillNameController = TextEditingController();

  @override
  void dispose() {
    _pillNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now()
        .add(const Duration(days: 2)); // Default end date: 7 days from now
    _isNext = widget.isNext;
    if (widget.pill != null) {
      Pill selectedPill = widget.pill ??
          Pill(
            name: '',
            dateTimes: [],
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            selectedDays: _selectedDays,
            times: _times,
          );
      print(DateTime.now());
      print(selectedPill.startDate);
      print(selectedPill.endDate);
      _startDate = selectedPill.startDate;
      _endDate = selectedPill.endDate;
      _selectedDays = selectedPill.selectedDays;
      _times = selectedPill.times;
      _pillNameController = TextEditingController(text: selectedPill.name);
    }
  }

  void addTime(Time newTime) {
    bool containsTime = _times.contains(newTime);
    if (containsTime) {
      showToast(context, ToastificationType.warning, '중복된 시간은 넣을 수 없습니다.');
    } else {
      setState(() {
        _times.add(newTime);
        _times.sort((a, b) => compareTime(a, b));
      });
    }
  }

  void onTimeChanged(int index, Time newTime) {
    setState(() {
      _times[index] = newTime;
      _times.sort((a, b) => compareTime(a, b));
    });
  }

  void showTimePicker(int index) {
    Navigator.of(context).push(
      showPicker(
        iosStylePicker: true,
        context: context,
        value: _times[index],
        sunrise: const TimeOfDay(hour: 6, minute: 0), // optional
        sunset: const TimeOfDay(hour: 18, minute: 0), // optional
        duskSpanInMinutes: 120, // optional
        onChange: (newTime) {
          onTimeChanged(index,
              Time(hour: newTime.hour, minute: newTime.minute, second: 0));
        },
      ),
    );
  }

  String _getFormattedTime(int hour, int minute) {
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _deletePillsForUser(String? deviceId, String? name) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference userRef = firestore.collection('user').doc(deviceId);
      DocumentSnapshot userSnapshot = await userRef.get();

      // 기존 pills 데이터 가져오기
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

  Future<void> _insertPillsForUser(String? deviceId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference userRef = firestore.collection('user').doc(deviceId);
      DocumentSnapshot userSnapshot = await userRef.get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      // _startDate ~ _endDate 범위 내의 모든 날짜를 확인하고 선택된 요일에 해당하는 날짜에 시간 데이터를 저장합니다.
      List<Map<String, dynamic>> dateTimes = [];
      DateTime currentDate = _startDate;
      while (currentDate.isBefore(_endDate) ||
          currentDate.isAtSameMomentAs(_endDate)) {
        if (_selectedDays[currentDate.weekday - 1]) {
          // 선택된 요일에 해당하는 날짜인 경우 데이터를 Firestore에 저장
          for (var time in _times) {
            DateTime combinedDateTime = DateTime(currentDate.year,
                currentDate.month, currentDate.day, time.hour, time.minute);
            Map<String, dynamic> data = {
              'dateTime': combinedDateTime,
              'checked': false,
            };
            dateTimes.add(data);
          }
        }

        // 다음 날짜로 이동
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // 새로운 약 데이터 추가
      Map<String, dynamic> newPill = {
        'name': _pillNameController.text,
        'dateTimes': dateTimes,
        'startDate':
            DateTime(_startDate.year, _startDate.month, _startDate.day),
        'endDate':
            DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59),
        'selectedDays': _selectedDays,
        'times': timesToMapList(_times),
      };

      // 기존 pills 데이터가 있는지 확인하고 새로운 약 데이터를 추가
      List<dynamic> updatedPills = [];
      if (userData != null &&
          userData.containsKey('pills') &&
          userData['pills'] is List<dynamic>) {
        updatedPills = [...userData['pills'], newPill];
      } else {
        updatedPills = [newPill];
      }

      // 사용자 문서 업데이트
      await userRef.update({'pills': updatedPills});
    } catch (e) {
      // 오류 처리
      print('Error updating pills for user: $e');
    }
  }

  Future<void> _updateData(name) async {
    await _deletePillsForUser(widget.deviceId, name);
    await _insertPillsForUser(widget.deviceId);
    await widget.onRefresh();
    showToast(context, ToastificationType.success, '수정에 성공했습니다.');
    Navigator.of(context).pop();
  }

  Future<void> _insertData() async {
    await _insertPillsForUser(widget.deviceId);
    await widget.onRefresh();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _isNext
          ? <Widget>[
              SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        '언제 알려드릴까요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _times.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    115, 16, 117, 19),
                                          ),
                                          onPressed: () =>
                                              showTimePicker(index),
                                          child: Text(
                                            _getFormattedTime(
                                                _times[index].hour,
                                                _times[index].minute),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (_times.length == 1) {
                                            showToast(
                                                context,
                                                ToastificationType.warning,
                                                '모든 알림을 삭제할 수 없습니다.');
                                          } else {
                                            setState(() {
                                              _times.removeAt(index);
                                            });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          minimumSize: Size.zero, // 최소 크기 설정
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 8), // 좌우 마진 설정
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                18), // 버튼을 더 네모지게 만듭니다.
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                index == _times.length - 1
                                    ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black45),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    showPicker(
                                                      iosStylePicker: true,
                                                      context: context,
                                                      value: _time,
                                                      sunrise: const TimeOfDay(
                                                          hour: 6,
                                                          minute:
                                                              0), // optional
                                                      sunset: const TimeOfDay(
                                                          hour: 18,
                                                          minute:
                                                              0), // optional
                                                      duskSpanInMinutes:
                                                          120, // optional
                                                      onChange: addTime,
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  "시간 추가",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            );
                          },
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black45),
                        onPressed: () {
                          setState(() {
                            _isNext = false;
                          });
                          widget.onChanged(false);
                        },
                        child: const Text(
                          "이전",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black45),
                        onPressed: widget.inputType == 'Add'
                            ? _insertData
                            : () => _updateData(widget.pill?.name),
                        child: Text(
                          widget.inputType == 'Add' ? "등록 하기" : "수정 하기",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          : <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      '어떤 약을 등록 하시나요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _pillNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '약 이름을 입력해주세요.',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        '기간',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectDateRange,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month),
                            const SizedBox(width: 5),
                            Text(
                              '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                              style: const TextStyle(
                                  fontSize: 16), // 텍스트 스타일 조정 가능
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        '요일',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              7,
                              (index) => InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedDays[index] =
                                        !_selectedDays[index];
                                  });
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _selectedDays[index]
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getWeekdayName(index),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ]),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Button(
                  text: '다음',
                  bgColor: const Color.fromARGB(255, 0, 104, 148),
                  textColor: Colors.white,
                  onPressed: () {
                    if (_pillNameController.text == "") {
                      showToast(
                          context, ToastificationType.warning, '약 이름을 입력해주세요.');
                    } else {
                      setState(() {
                        _isNext = true;
                      });
                      widget.onChanged(true);
                    }
                  },
                ),
              ),
            ],
    );
  }

  String _getWeekdayName(int index) {
    switch (index) {
      case 0:
        return '월';
      case 1:
        return '화';
      case 2:
        return '수';
      case 3:
        return '목';
      case 4:
        return '금';
      case 5:
        return '토';
      case 6:
        return '일';
      default:
        return '';
    }
  }

  Future<void> _selectDateRange() async {
    print(_startDate);
    print(_endDate);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
