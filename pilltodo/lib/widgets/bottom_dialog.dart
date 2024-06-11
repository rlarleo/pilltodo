import 'package:flutter/material.dart';

class BottomDialog extends StatelessWidget {
  final List<DialogOption> options;

  const BottomDialog({
    Key? key,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero, // 좌우 여백 없애기
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24), // 상단 여백
          ...options.map((option) {
            return option.widget;
          }).toList(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
      backgroundColor: Colors.white, // 배경색 설정
    );
  }
}

class DialogOption {
  final String text;
  final Function() onPressed;

  const DialogOption({
    required this.text,
    required this.onPressed,
  });

  Widget get widget {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.black), // 텍스트 색상 설정
      ),
    );
  }
}
