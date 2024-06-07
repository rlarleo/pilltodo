import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timeline_calendar/timeline/model/calendar_options.dart';
import 'package:flutter_timeline_calendar/timeline/model/datetime.dart';
import 'package:flutter_timeline_calendar/timeline/model/day_options.dart';
import 'package:flutter_timeline_calendar/timeline/model/headers_options.dart';
import 'package:flutter_timeline_calendar/timeline/provider/instance_provider.dart';
import 'package:flutter_timeline_calendar/timeline/utils/calendar_types.dart';
import 'package:flutter_timeline_calendar/timeline/utils/datetime_extension.dart';
import 'package:flutter_timeline_calendar/timeline/widget/timeline_calendar.dart';
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
  late CalendarDateTime selectedDateTime;
  late DateTime? weekStart;
  late DateTime? weekEnd;
  // ignore: avoid_init_to_null
  late String? deviceId = null;

  @override
  void initState() {
    super.initState();
    TimelineCalendar.calendarProvider = createInstance();
    selectedDateTime = TimelineCalendar.calendarProvider.getDateTime();
    getLatestWeek();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceId = Provider.of<DeviceProvider>(context).deviceId;
    _pillsFuture = getAlarms(deviceId, selectedDateTime.toDateTime());
  }

  getLatestWeek() {
    setState(() {
      weekStart = selectedDateTime.toDateTime().findFirstDateOfTheWeek();
      weekEnd = selectedDateTime.toDateTime().findLastDateOfTheWeek();
    });
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DateTimeCheck>>(
        future: _pillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                color: const Color.fromARGB(255, 221, 186, 173),
                child: CustomScrollView(slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 40,
                        ),
                        IgnorePointer(
                          ignoring: true,
                          child: _timelineCalendar(),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            );
          } else {
            List<DateTimeCheck> pills = snapshot.data ?? [];
            pills.sort((a, b) => a.name.compareTo(b.name));
            pills.sort((a, b) => a.dateTime.compareTo(b.dateTime));
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
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  _timelineCalendar(),
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
                    dateTime:
                        DateFormat('yyyy.MM.dd hh:mm').format(pill.dateTime),
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
                              colors: Colors.red,
                              tag: index,
                            );
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
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

  _timelineCalendar() {
    return TimelineCalendar(
      calendarType: CalendarType.GREGORIAN,
      calendarLanguage: "en",
      calendarOptions: CalendarOptions(
        viewType: ViewType.DAILY,
        toggleViewType: true,
        headerMonthElevation: 10,
        headerMonthShadowColor: Colors.black26,
        headerMonthBackColor: Colors.transparent,
      ),
      dayOptions: DayOptions(
        compactMode: true,
        dayFontSize: 14.0,
        disableFadeEffect: true,
        weekDaySelectedColor: const Color(0xff3AC3E2),
        // differentStyleForToday: true,
        // todayBackgroundColor: const Color.fromARGB(255, 19, 218, 112),
        selectedBackgroundColor: const Color(0xff3AC3E2),
        // todayTextColor: Colors.white,
      ),
      headerOptions: HeaderOptions(
          weekDayStringType: WeekDayStringTypes.SHORT,
          monthStringType: MonthStringTypes.FULL,
          backgroundColor: const Color(0xff3AC3E2),
          headerTextSize: 14,
          headerTextColor: Colors.black),
      onChangeDateTime: (dateTime) {
        print("Date Change $dateTime");
        selectedDateTime = dateTime;
        _pillsFuture = getAlarms(deviceId, dateTime.toDateTime());
        getLatestWeek();
      },
      onDateTimeReset: (resetDateTime) {
        print("Date Reset $resetDateTime");
        selectedDateTime = resetDateTime;
        _pillsFuture = getAlarms(deviceId, resetDateTime.toDateTime());
        getLatestWeek();
      },
      onMonthChanged: (monthDateTime) {
        print("Month Change $monthDateTime");
        selectedDateTime = monthDateTime;
        _pillsFuture = getAlarms(deviceId, monthDateTime.toDateTime());
        getLatestWeek();
      },
      onYearChanged: (yearDateTime) {
        print("Year Change $yearDateTime");
        selectedDateTime = yearDateTime;
        _pillsFuture = getAlarms(deviceId, yearDateTime.toDateTime());
        getLatestWeek();
      },
      dateTime: selectedDateTime,
    );
  }
}
