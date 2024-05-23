import 'package:flutter/material.dart';

class CheckCard extends StatelessWidget {
  final String pillName;
  final IconData icon;
  final double index;
  const CheckCard(
      {super.key,
      required this.pillName,
      required this.icon,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
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
                        const Text(
                          '6 428',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'EUR',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                          ),
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
        ));
  }
}
