import 'package:flutter/material.dart';

class CheckCard extends StatelessWidget {
  final String pillName;
  final String dateTime;
  final IconData? icon;
  final double index;
  final VoidCallback onPressed; // 추가: 카드를 눌렀을 때 호출될 콜백

  const CheckCard({
    super.key,
    required this.pillName,
    required this.dateTime,
    required this.icon,
    required this.index,
    required this.onPressed, // 추가: onPressed 콜백
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed, // 추가: 카드를 눌렀을 때 onPressed 콜백 호출
        child: Transform.translate(
          offset: Offset(0, -30 * index),
          child: Container(
            margin: const EdgeInsets.only(
              top: 10.0,
              bottom: 0,
              left: 20.0,
              right: 20.0,
            ),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pillName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            dateTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                        ],
                      )
                    ],
                  ),
                  Transform.scale(
                      scale: 2.2,
                      child: Transform.translate(
                        offset: const Offset(-5, -8),
                        child: Icon(icon,
                            color: const Color.fromARGB(108, 131, 0, 0),
                            size: 88),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
