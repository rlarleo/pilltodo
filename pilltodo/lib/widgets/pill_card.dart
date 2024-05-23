import 'package:flutter/material.dart';

class PillCard extends StatelessWidget {
  final String pillName;
  final IconData icon;
  final bool isInverted;
  final double index;
  const PillCard(
      {super.key,
      required this.pillName,
      required this.icon,
      required this.isInverted,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0, -30 * index),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isInverted ? Colors.white : Colors.black,
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
                      style: TextStyle(
                        color: isInverted ? Colors.black : Colors.white,
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
                          '6 428',
                          style: TextStyle(
                            color: isInverted ? Colors.black : Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'EUR',
                          style: TextStyle(
                            color: isInverted
                                ? Colors.black.withOpacity(0.8)
                                : Colors.white.withOpacity(0.8),
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
                      offset: const Offset(-5, 12),
                      child: Icon(icon,
                          color: isInverted ? Colors.black : Colors.white,
                          size: 88),
                    ))
              ],
            ),
          ),
        ));
  }
}
