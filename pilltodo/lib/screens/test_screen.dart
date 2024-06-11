import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:pilltodo/widgets/example_card.dart';

class SwiperPage extends StatefulWidget {
  const SwiperPage({
    super.key,
  });

  @override
  State<SwiperPage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<SwiperPage> {
  final AppinioSwiperController controller = AppinioSwiperController();

  List<ExampleCandidateModel> candidates = [
    ExampleCandidateModel(
      name: 'Eight, 8',
      job: 'Manager',
      city: 'Town',
      color: gradientPink,
    ),
    ExampleCandidateModel(
      name: 'Seven, 7',
      job: 'Manager',
      city: 'Town',
      color: gradientBlue,
    ),
    ExampleCandidateModel(
      name: 'Six, 6',
      job: 'Manager',
      city: 'Town',
      color: gradientPurple,
    ),
    ExampleCandidateModel(
      name: 'Five, 5',
      job: 'Manager',
      city: 'Town',
      color: gradientRed,
    ),
    ExampleCandidateModel(
      name: 'Four, 4',
      job: 'Manager',
      city: 'Town',
      color: gradientPink,
    ),
    ExampleCandidateModel(
      name: 'Three, 3',
      job: 'Manager',
      city: 'Town',
      color: gradientBlue,
    ),
    ExampleCandidateModel(
      name: 'Two, 2',
      job: 'Manager',
      city: 'Town',
      color: gradientPurple,
    ),
    ExampleCandidateModel(
      name: 'One, 1',
      job: 'Manager',
      city: 'Town',
      color: gradientRed,
    ),
  ];
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      _shakeCard();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .75,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                  top: 50,
                  bottom: 40,
                ),
                child: AppinioSwiper(
                  invertAngleOnBottomDrag: true,
                  backgroundCardCount: 3,
                  swipeOptions: const SwipeOptions.all(),
                  controller: controller,
                  onCardPositionChanged: (
                    SwiperPosition position,
                  ) {},
                  onSwipeEnd: _swipeEnd,
                  onEnd: _onEnd,
                  cardCount: candidates.length,
                  cardBuilder: (BuildContext context, int index) {
                    return ExampleCard(candidate: candidates[index]);
                  },
                  loop: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        print('The card was swiped to the : ${activity.direction}');
        print('previous index: $previousIndex, target index: $targetIndex');
        print(candidates);
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

  // Animates the card back and forth to teach the user that it is swipable.
  Future<void> _shakeCard() async {
    const double distance = 30;
    // We can animate back and forth by chaining different animations.
    await controller.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await controller.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    // We need to animate back to the center because `animateTo` does not center
    // the card for us.
    await controller.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}

class ExampleCandidateModel {
  String? name;
  String? job;
  String? city;
  LinearGradient? color;

  ExampleCandidateModel({
    this.name,
    this.job,
    this.city,
    this.color,
  });
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
