import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pilltodo/icons/custom_icons.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:pilltodo/widgets/check_card.dart';
import 'package:provider/provider.dart';

class PillScreen extends StatefulWidget {
  const PillScreen({super.key});

  @override
  State<PillScreen> createState() => _PillScreenState();
}

class _PillScreenState extends State<PillScreen> {
  Future<List<DateTimeCheck>>? _pillsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pillsFuture = _getPills();
  }

  Future<List<DateTimeCheck>> _getPills() async {
    String? deviceId = Provider.of<DeviceProvider>(context).deviceId;
    if (deviceId != null) {
      print("@@@@@@@@@@@");
      print(deviceId);
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('user').doc(deviceId);
      DocumentSnapshot userSnapshot = await userRef.get();

      // 기존 pills 데이터 가져오기
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null &&
          userData.containsKey('pills') &&
          userData['pills'] is List<dynamic>) {
        List<dynamic> pillDataList = userData['pills'];
        List<DateTimeCheck> allDateTimeChecks = [];

        // 캘린더의 데이터가 보여야함
        DateTime today = DateTime.now();

        DateTime todayStart = DateTime(today.year, today.month, today.day);
        DateTime todayEnd = todayStart
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1));

        for (var pillData in pillDataList) {
          var pill = Pill.fromMap(pillData as Map<String, dynamic>);
          if (today.isAfter(pill.startDate) && today.isBefore(pill.endDate)) {
            for (var dateTimeCheck in pill.dateTimes) {
              if (dateTimeCheck.dateTime.isAfter(todayStart) &&
                  dateTimeCheck.dateTime.isBefore(todayEnd)) {
                dateTimeCheck.name = pill.name;
                allDateTimeChecks.add(dateTimeCheck);
              }
            }
          }
        }
        return allDateTimeChecks;
      }
    }

    return []; // 데이터가 없는 경우 빈 리스트 반환
  }

  Future<void> _updateCheckedStatus(
      String pillName, DateTime dateTime, bool checked) async {
    print(checked);
    String? deviceId =
        Provider.of<DeviceProvider>(context, listen: false).deviceId;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('user').doc(deviceId);
    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userSnapshot.exists) {
      // 'pills' 필드가 있는지 확인
      if (userData != null && userData.containsKey('pills')) {
        List<dynamic> pills = List<dynamic>.from(userData['pills']);
        // 해당 약을 찾아서 업데이트
        for (int i = 0; i < pills.length; i++) {
          if (pills[i]['name'] == pillName) {
            List<dynamic> dateTimes = List<dynamic>.from(pills[i]['dateTimes']);

            // dateTimes 배열의 해당 항목의 'checked' 값을 업데이트
            for (int j = 0; j < dateTimes.length; j++) {
              DateTime currentDateTime =
                  (dateTimes[j]['dateTime'] as Timestamp).toDate();
              if (currentDateTime.isAtSameMomentAs(dateTime)) {
                dateTimes[j]['checked'] = checked;
              }
            }

            // 업데이트된 dateTimes를 pills 리스트에 할당
            pills[i]['dateTimes'] = dateTimes;

            // Firestore에 업데이트된 데이터 저장
            await userRef.update({'pills': pills}).then((_) {
              // 업데이트 성공
              print('Firestore 업데이트 성공');
            }).catchError((error) {
              // 업데이트 중 오류 발생
              print('Firestore 업데이트 오류: $error');
            });
            break; // 약을 찾았으므로 루프 종료
          }
        }
      }
    }
  }

  var slivers = SliverToBoxAdapter(
    child: Container(
      height: 200,
      color: Colors.brown,
      alignment: Alignment.center,
      child: const Text(
        'Calender',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DateTimeCheck>>(
        future: _pillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                color: const Color.fromARGB(255, 221, 186, 173),
                child: CustomScrollView(slivers: <Widget>[slivers]),
              ),
            );
          } else {
            List<DateTimeCheck> pills = snapshot.data ?? [];
            return _buildPillList(pills);
          }
        });
  }

  Widget _buildPillList(List<DateTimeCheck> pills) {
    // pills 데이터를 사용하여 UI를 빌드하는 코드를 여기에 작성하세요.
    // 예를 들어 ListView.builder 또는 SliverList를 사용하여 리스트를 만들 수 있습니다.
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 221, 186, 173),
        child: CustomScrollView(
          slivers: <Widget>[
            slivers,
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  DateTimeCheck pill =
                      pills[index]; // 현재 인덱스에 해당하는 Pill 객체 가져오기
                  return CheckCard(
                    pillName: pill.name,
                    dateTime:
                        DateFormat('yyyy.MM.dd hh:mm').format(pill.dateTime),
                    icon: pill.checked ? Custom_Icons.check_1 : null,
                    index: 0,
                    onPressed: () {
                      _updateCheckedStatus(
                          pill.name, pill.dateTime, !pill.checked);
                      setState(() {
                        // 해당 카드를 눌렀을 때 checked 값을 변경합니다.
                        pills[index].checked = !pills[index].checked;
                      });
                    },
                  );
                },
                childCount: pills.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                color: Colors.red,
                alignment: Alignment.center,
                child: const Text(
                  'Bottom Container',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
