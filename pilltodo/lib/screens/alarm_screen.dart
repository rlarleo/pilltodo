import 'package:flutter/material.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/utils/utils.dart';
import 'package:pilltodo/widgets/add_card.dart';
import 'package:pilltodo/widgets/pill_card.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  Future<User?>? _userFuture;
  Future<List<Pill>>? _pillsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pillsFuture = getPills(context);
    _userFuture = getUser(context);
  }

  Future<void> _refreshPills(BuildContext context) async {
    setState(() {
      _pillsFuture = getPills(context);
    });
    print('refersh');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          final user = snapshot.data;

          return Scaffold(
            backgroundColor: Colors.brown,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '안녕, ${user?.name ?? ""}${user?.gender ?? ""} ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.8),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      '1234',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pills',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder<List<Pill>>(
                      future: _pillsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          final pillData = snapshot.data ?? [];

                          // AddCard는 고정된 위치에 추가
                          pillData.add(
                            Pill(
                              name: '_addCard',
                              dateTimes: [],
                              startDate: DateTime.now(),
                              endDate: DateTime.now(),
                              selectedDays: [],
                              times: [],
                            ),
                          );
                          pillData.sort((a, b) => a.name.compareTo(b.name));
                          pillData.sort(
                              (a, b) => a.startDate.compareTo(b.startDate));

                          return ListView.builder(
                            shrinkWrap:
                                true, // ScrollView 안에 ListView를 사용할 때 필요
                            physics:
                                const NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
                            itemCount: pillData.length,
                            itemBuilder: (context, index) {
                              final pill = pillData[index];
                              if (pill.name == '_addCard') {
                                return AddCard(
                                  pillName: 'test',
                                  icon: Icons.add_circle_outline_rounded,
                                  isInverted: index % 2 == 0,
                                  index: index.toDouble(),
                                  onRefresh: () => _refreshPills(context),
                                );
                              } else {
                                return PillCard(
                                  pill: pill,
                                  icon: Icons.notifications_off_outlined,
                                  isInverted: index % 2 == 0,
                                  index: index.toDouble(),
                                  onRefresh: () => _refreshPills(context),
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
