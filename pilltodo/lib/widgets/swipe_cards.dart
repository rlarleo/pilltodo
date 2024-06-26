import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:pilltodo/model/device.dart';
import 'package:pilltodo/widgets/swipe_card.dart';

class SwipeCards extends StatefulWidget {
  final List<Pill> pills;
  final Future<void> Function() onRefresh;

  const SwipeCards({
    super.key,
    required this.pills,
    required this.onRefresh,
  });

  @override
  State<SwipeCards> createState() => SwipeCardsState();
}

class SwipeCardsState extends State<SwipeCards> {
  final AppinioSwiperController controller = AppinioSwiperController();
  bool isDisposed = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0)).then((_) {
      _shakeCard();
    });
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .45,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 50,
                    bottom: 40,
                  ),
                  child: AppinioSwiper(
                    invertAngleOnBottomDrag: true,
                    backgroundCardCount:
                        widget.pills.length > 2 ? 2 : widget.pills.length - 1,
                    swipeOptions: const SwipeOptions.all(),
                    controller: controller,
                    onCardPositionChanged: (
                      SwiperPosition position,
                    ) {},
                    onSwipeEnd: _swipeEnd,
                    onEnd: _onEnd,
                    cardCount: widget.pills.length,
                    cardBuilder: (BuildContext context, int index) {
                      return SwipeCard(
                        pill: widget.pills[index],
                        onRefresh: widget.onRefresh,
                      );
                    },
                    loop: true,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        print('The card was swiped to the : ${activity.direction}');
        print('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        print('A ${activity.direction.name} swipe was undone.');
        print('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        print('A swipe was cancelled');
        break;
      case DrivenActivity():
        print('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    print('end reached!');
  }

  Future<void> _shakeCard() async {
    const double distance = 30;
    try {
      if (isDisposed) return Future<void>(() {});
      await controller.animateTo(
        const Offset(-distance, 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      if (isDisposed) return Future<void>(() {});
      await controller.animateTo(
        const Offset(distance, 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      if (isDisposed) return Future<void>(() {});
      await controller.animateTo(
        const Offset(0, 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      return Future<void>(() {});
    }
  }
}

const LinearGradient gradientRed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFF3868),
    Color(0xFFFFB49A),
  ],
);

const LinearGradient gradientPurple = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF736EFE),
    Color(0xFF62E4EC),
  ],
);

const LinearGradient gradientBlue = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0BA4E0),
    Color(0xFFA9E4BD),
  ],
);

const LinearGradient gradientPink = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFF6864),
    Color(0xFFFFB92F),
  ],
);

const LinearGradient kNewFeedCardColorsIdentityGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF7960F1),
    Color(0xFFE1A5C9),
  ],
);
