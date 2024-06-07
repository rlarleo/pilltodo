import 'package:flutter/material.dart';
import 'package:pilltodo/widgets/emoji_firework_widget.dart';

class EmojiFireworkPage extends StatefulWidget {
  const EmojiFireworkPage({super.key});
  @override
  State<EmojiFireworkPage> createState() => _EmojiFireworkPageState();
}

class _EmojiFireworkPageState extends State<EmojiFireworkPage> {
  EmojiFireWork emojiFireWork = EmojiFireWork(
      emojiAsset: const AssetImage('assets/images/heart_icon.png'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12.withOpacity(0.2),
      body: Stack(
        alignment: Alignment.center,
        children: [
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
                const Text(
                  "💣",
                  style: TextStyle(fontSize: 60),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  emojiFireWork.addFireworkWidget(Offset.zero);
                });
              },
              child: const Text("Tap Button"),
            ),
          ),
        ],
      ),
    );
  }
}
