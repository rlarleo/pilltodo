import 'package:flutter/material.dart';
import 'package:pilltodo/icons/custom_icons.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required NotchBottomBarController controller,
    required PageController pageController,
  })  : _controller = controller,
        _pageController = pageController;

  final NotchBottomBarController _controller;
  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedNotchBottomBar(
      notchBottomBarController: _controller,
      color: Colors.white,
      showLabel: true,
      textOverflow: TextOverflow.visible,
      maxLine: 1,
      shadowElevation: 5,
      kBottomRadius: 28.0,
      removeMargins: false,
      bottomBarWidth: 500,
      showShadow: false,
      durationInMilliSeconds: 300,
      itemLabelStyle: const TextStyle(fontSize: 10),
      elevation: 1,
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: const Icon(
            Custom_Icons.add_alarm,
            color: Colors.blueGrey,
          ),
          activeItem: Icon(
            Custom_Icons.add_alarm,
            color: Theme.of(context).primaryColor,
          ),
        ),
        BottomBarItem(
          inActiveItem: const Icon(Custom_Icons.pills, color: Colors.blueGrey),
          activeItem: Icon(
            Custom_Icons.pills,
            color: Theme.of(context).primaryColor,
          ),
        ),
        BottomBarItem(
          inActiveItem: const Icon(
            Icons.settings,
            color: Colors.blueGrey,
          ),
          activeItem: Icon(
            Icons.settings,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
      onTap: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      kIconSize: 24.0,
    );
  }
}
