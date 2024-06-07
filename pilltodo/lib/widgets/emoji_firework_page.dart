import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pilltodo/screens/pill_screen.dart';
import 'package:pilltodo/widgets/emoji_firework_widget.dart';

class EmojiFireworkPage extends StatefulWidget {
  final Color colors;
  final int tag;

  const EmojiFireworkPage({super.key, required this.colors, required this.tag});
  @override
  State<EmojiFireworkPage> createState() => _EmojiFireworkPageState();
}

class _EmojiFireworkPageState extends State<EmojiFireworkPage>
    with TickerProviderStateMixin {
  EmojiFireWork emojiFireWork = EmojiFireWork(
      emojiAsset: const AssetImage('assets/images/heart_icon.png'));

  // 카드 사이즈.
  static const double _cardWidth = 320;
  static const double _cardHeight = 200;

  // 카드 애니메이션.
  late AnimationController _cardRotateController;
  late AnimationController _cardBounceController;

  // 바운스 애니메이션.
  final Duration _bounceAnimationDuration = const Duration(milliseconds: 100);

  // 카드 애니메이션 설정.
  void _setCardRotateAnimation() {
    // 카드 회전 애니메이션.
    _cardRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 속도를 빠르게 설정
    )
      ..addListener(() => setState(() {}))
      ..repeat(reverse: true); // 반복하면서 방향을 반대로

    // 카드 바운스 애니메이션.
    _cardBounceController = AnimationController(
      vsync: this,
      duration: _bounceAnimationDuration,
      lowerBound: 0.0,
      upperBound: 10.0,
    )..addListener(() => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _setCardRotateAnimation();
    setState(() {
      emojiFireWork.addFireworkWidget(Offset.zero, 2.0);
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        emojiFireWork.addFireworkWidget(Offset.zero, 4.0);
      });
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        emojiFireWork.addFireworkWidget(Offset.zero, 3.0);
      });
    });
  }

  @override
  void dispose() {
    _cardRotateController.dispose();
    _cardBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12.withOpacity(0.2),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(),
            ),
          ),
          // 카드 화면.
          SafeArea(
            child: Column(
              children: [
                // 카드.
                _cards(),

                // 구매 버튼.
                _paymentButton(),
              ],
            ),
          ),
          Positioned(
            top: 100,
            child: Container(
              color: Colors.black26,
            ),
          ),
          Container(
            constraints: const BoxConstraints.expand(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Stack(
                  children: emojiFireWork.fireworkWidgets.values.toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 카드.
  Expanded _cards() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: widget.tag,
            child: Transform.rotate(
              angle: _cardRotateController.value *
                  (math.pi / 15), // 각도를 조정하여 좌우 균형을 맞춤
              child: Transform(
                alignment: Alignment.topLeft,
                transform: Matrix4.identity()
                  // 회전.
                  ..rotateX(_cardBounceController.value * (math.pi / 400))
                  ..rotateY(_cardBounceController.value * (math.pi / 400)),
                child: _giftCard(index: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 기프트 카드.
  Container _giftCard({required int index}) {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.colors,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(10, 10),
          ),
        ],
      ),
      child: (index == 0)
          ? const Material(
              type: MaterialType.transparency,
              child: Text(
                '참 잘했어요',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // 구매 버튼.
  Container _paymentButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20) +
          const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.black45),
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const PillScreen();
                },
              ),
            );
          },
          child: const Text(
            "시간 추가",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}