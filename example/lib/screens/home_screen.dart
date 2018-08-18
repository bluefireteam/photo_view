import 'package:example/screens/hero_example.dart';
import 'package:flutter/material.dart';
import './app_bar.dart';
import './full_screen_examples.dart';
import './inline_examples.dart';

class HomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Photo View"
          ),
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: const Text(
              "See bellow examples of some of the most common photo view usage cases",
              style: const TextStyle(
                fontSize: 18.0
              ),
            ),
          ),
          new Expanded(
            child: new ListView(
              children: <Widget>[
                _buildItem(context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenExamples(),
                        ),
                      );
                    },
                    text: "Full screen"
                ),
                _buildItem(context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InlineExamples(),
                        ),
                      );
                    },
                    text: "Part of the screen"
                ),
                _buildItem(context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HeroExample(),
                        ),
                      );
                    },
                    text: "Hero animation"
                ),
                _buildItem(context,
                    text: "Gallery (TODO)"
                ),
              ],
            )
          )


        ],
      ),
    );
  }

  Widget _buildItem(context, {
    String text,
    Function onPressed
  }){
    return new FlatButton(
      padding: const EdgeInsets.symmetric(
          vertical: 25.0,
          horizontal: 20.0
      ),
      child: new Text(
        text,
        style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700
        ),
      ),
      onPressed: onPressed,
    );
  }
}
