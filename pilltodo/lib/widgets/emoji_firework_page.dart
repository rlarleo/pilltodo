import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pilltodo/main.dart';
import 'package:pilltodo/widgets/button.dart';
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
  late AnimationController _cardBounceController;

  // 바운스 애니메이션.
  final Duration _bounceAnimationDuration = const Duration(milliseconds: 100);

  // 카드 애니메이션 설정.
  void _setCardRotateAnimation() {
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
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(),
            ),
          ),
          // 카드 화면.
          SafeArea(
            child: Column(
              children: [
                _cards(),
                _okButton(),
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
            child: Transform(
              alignment: Alignment.topLeft,
              transform: Matrix4.identity()
                // 회전.
                ..rotateX(_cardBounceController.value * (math.pi / 400))
                ..rotateY(_cardBounceController.value * (math.pi / 400)),
              child: _giftCard(index: 0),
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
        child: Material(
          type: MaterialType.transparency,
          child: Stack(children: [
            const Text(
              '참 잘했어요',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            Positioned(
              bottom: 0, // 원하는 수직 위치
              left: 0, // 원하는 수평 위치
              right: 0, // 원하는 수평 위치
              child: Center(
                child: Image.asset(
                  'assets/images/emoji5.gif',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ]),
        ));
  }

  Padding _okButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Button(
        text: '확인',
        bgColor: Colors.black45,
        textColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              transitionDuration: const Duration(milliseconds: 200),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (context, animation, secondaryAnimation) {
                return const MyApp();
              },
            ),
          );
        },
      ),
    );
  }
}
