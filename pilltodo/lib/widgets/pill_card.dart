import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pilltodo/widgets/pill_input.dart';

class PillCard extends StatefulWidget {
  final String pillName;
  final IconData icon;
  final bool isInverted;
  final double index;

  const PillCard({
    super.key,
    required this.pillName,
    required this.icon,
    required this.isInverted,
    required this.index,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PillCardState createState() => _PillCardState();
}

class _PillCardState extends State<PillCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _isPressed ? 1.05 : 1,
      child: Transform.translate(
        offset: Offset(0, -30 * widget.index),
        child: InkWell(
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
            });
          },
          onTap: () {
            AwesomeDialog(
              context: context,
              animType: AnimType.scale,
              headerAnimationLoop: false,
              dialogType: DialogType.success,
              showCloseIcon: true,
              body: const PillInputForm(),
              btnOkOnPress: () {
                debugPrint('OnClick');
              },
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (type) {
                debugPrint('Dialog Dismiss from callback $type');
              },
            ).show();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: widget.isInverted ? Colors.white : Colors.black,
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
                        widget.pillName,
                        style: TextStyle(
                          color:
                              widget.isInverted ? Colors.black : Colors.white,
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
                              color: widget.isInverted
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'EUR',
                            style: TextStyle(
                              color: widget.isInverted
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
                    scale: 1,
                    child: Transform.translate(
                      offset: const Offset(-20, -5),
                      child: Icon(
                        widget.icon,
                        color: widget.isInverted ? Colors.black : Colors.white,
                        size: 88,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}