import 'package:flutter/material.dart';

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
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[200 + bottom[index] % 4 * 100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    height: 150.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 50,
                    ),
                    child: Text('Item: ${bottom[index]}'),
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
