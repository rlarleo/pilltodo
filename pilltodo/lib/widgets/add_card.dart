import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pilltodo/utils/utils.dart';
import 'package:pilltodo/widgets/pill_input.dart';

class AddCard extends StatefulWidget {
  final String pillName;
  final IconData icon;
  final bool isInverted;
  final double index;

  const AddCard({
    super.key,
    required this.pillName,
    required this.icon,
    required this.isInverted,
    required this.index,
  });

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  bool _isPressed = false;
  bool _isNext = false;
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
              body: PillInputForm(
                  isNext: _isNext,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isNext = newValue;
                    });
                  },
                  parentContext: context),
              btnOkOnPress: getOkButtonPressHandler(_isNext),
              btnOkIcon: getOkButtonIcon(_isNext),
              onDismissCallback: (type) {
                _isNext = false;
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1,
                    child: Icon(
                      widget.icon,
                      color: widget.isInverted ? Colors.black : Colors.white,
                      size: 88,
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
