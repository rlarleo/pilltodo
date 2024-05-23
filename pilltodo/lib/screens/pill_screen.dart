import 'package:flutter/material.dart';
import 'package:pilltodo/icons/custom_icons.dart';
import 'package:pilltodo/widgets/check_card.dart';

class PillScreen extends StatelessWidget {
  const PillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<int> bottom = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 221, 186, 173),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: Colors.brown,
                alignment: Alignment.center,
                child: const Text(
                  'Calender',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return const CheckCard(
                    pillName: 'test',
                    icon: Custom_Icons.check_1,
                    index: 0,
                  );
                },
                childCount: bottom.length,
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

void main() {
  runApp(const MaterialApp(
    home: PillScreen(),
  ));
}
