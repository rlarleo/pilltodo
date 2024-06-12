import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pilltodo/icons/custom_icons.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/provider/device_provider.dart';
import 'package:pilltodo/widgets/check_card.dart';
import 'package:pilltodo/widgets/emoji_firework_page.dart';
import 'package:provider/provider.dart';
import 'package:pilltodo/utils/utils.dart';

class PillScreen extends StatefulWidget {
  const PillScreen({
    super.key,
  });
  @override
  State<PillScreen> createState() => _PillScreenState();
}

class _PillScreenState extends State<PillScreen> {
  Future<List<DateTimeCheck>>? _pillsFuture;
  late DateTime _focusDate = DateTime.now();
  late DateTime? weekStart;
  late DateTime? weekEnd;
  // ignore: avoid_init_to_null
  late String? deviceId = null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceId = Provider.of<DeviceProvider>(context).deviceId;
    _pillsFuture = getAlarms(deviceId, _focusDate);
  }

  Future<void> _updateCheckedStatus(
      String pillName, DateTime dateTime, bool checked) async {
    String? deviceId =
        Provider.of<DeviceProvider>(context, listen: false).deviceId;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userRef = firestore.collection('user').doc(deviceId);
    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userSnapshot.exists) {
      if (userData != null && userData.containsKey('pills')) {
        List<dynamic> pills = List<dynamic>.from(userData['pills']);
        for (int i = 0; i < pills.length; i++) {
          if (pills[i]['name'] == pillName) {
            List<dynamic> dateTimes = List<dynamic>.from(pills[i]['dateTimes']);

            for (int j = 0; j < dateTimes.length; j++) {
              DateTime currentDateTime =
                  (dateTimes[j]['dateTime'] as Timestamp).toDate();
              if (currentDateTime.isAtSameMomentAs(dateTime)) {
                dateTimes[j]['checked'] = checked;
              }
            }

            pills[i]['dateTimes'] = dateTimes;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DateTimeCheck>>(
        future: _pillsFuture,
        builder: (context, snapshot) {
          List<DateTimeCheck> pills = snapshot.data ?? [];
          pills.sort((a, b) => a.name.compareTo(b.name));
          pills.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return _buildPillList(pills);
        });
  }

  Widget _buildPillList(List<DateTimeCheck> pills) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 60,
                  ),
                  _timelineCalendar(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  DateTimeCheck pill =
                      pills[index]; // 현재 인덱스에 해당하는 Pill 객체 가져오기
                  return CheckCard(
                    pillName: pill.name,
                    dateTime: DateFormat('hh:mm a').format(pill.dateTime),
                    icon: pill.checked ? Custom_Icons.check_1 : null,
                    index: 0,
                    onPressed: () async {
                      _updateCheckedStatus(
                          pill.name, pill.dateTime, !pill.checked);
                      setState(() {
                        pills[index].checked = !pills[index].checked;
                      });

                      Navigator.of(context)
                          .push(
                        PageRouteBuilder(
                          opaque: false,
                          transitionDuration: const Duration(milliseconds: 200),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 200),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return EmojiFireworkPage(
                              colors: const Color.fromARGB(255, 207, 107, 100),
                              tag: index,
                            );
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = 0.0;
                            const end = 1.0;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return ScaleTransition(
                              scale: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      )
                          .then((value) {
                        setState(() {
                          // setState를 호출하여 화면을 다시 그립니다.
                        });
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
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _timelineCalendar() {
    return EasyInfiniteDateTimeLine(
      selectionMode: const SelectionMode.autoCenter(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      focusDate: _focusDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      onDateChange: (selectedDate) {
        setState(() {
          _focusDate = selectedDate;
        });
        _pillsFuture = getAlarms(deviceId, selectedDate);
      },
      dayProps: const EasyDayProps(
        // You must specify the width in this case.
        width: 50.0,
        // The height is not required in this case.
        height: 50.0,
      ),
      itemBuilder: (
        BuildContext context,
        DateTime date,
        bool isSelected,
        VoidCallback onTap,
      ) {
        return InkResponse(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor:
                isSelected ? Colors.blueGrey : Colors.blueGrey.withOpacity(0.2),
            radius: 32.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    EasyDateFormatter.shortDayName(date, "en_US"),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
