import 'package:flutter/material.dart';
import './app_bar.dart';
import './custom_child_examples.dart';
import './full_screen_examples.dart';
import './gallery_example.dart';
import './hero_example.dart';
import './inline_examples.dart';
import './rotation_examples.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(title: "Photo View"),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: const Text(
              "See bellow examples of some of the most common photo view usage cases",
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
          Expanded(
              child: ListView(
            children: <Widget>[
              _buildItem(context, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenExamples(),
                  ),
                );
              }, text: "Full screen"),
              _buildItem(context, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InlineExamples(),
                  ),
                );
              }, text: "Part of the screen"),
              _buildItem(context, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RotationExamples(),
                  ),
                );
              }, text: "Rotation Gesture"),
              _buildItem(context, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HeroExample(),
                  ),
                );
              }, text: "Hero animation"),
              _buildItem(context, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GalleryExample(),
                  ),
                );
              }, text: "Gallery"),
              _buildItem(context, onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomChildExample(),
                  ),
                );
              }, text: "Custom child"),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildItem(context, {String text, Function onPressed}) {
    return FlatButton(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
      ),
      onPressed: onPressed,
    );
  }
}
