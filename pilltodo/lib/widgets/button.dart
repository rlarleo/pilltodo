import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onPressed; // 선택 이벤트를 처리하는 콜백 함수

  const Button({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.onPressed, // 선택 이벤트를 처리하는 콜백 함수를 매개변수로 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // 버튼을 눌렀을 때 onPressed 콜백 함수 호출
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(45),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
