import 'package:flutter/material.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/screens/test_screen.dart';
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
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
                          return pillData.isNotEmpty
                              ? SwiperPage(
                                  pills: pillData,
                                  onRefresh: () => _refreshPills(context),
                                )
                              : Center(child: Text('등록 하슈'));
                        }
                      },
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
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
