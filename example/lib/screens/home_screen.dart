import 'package:example/screens/app_bar.dart';
import 'package:example/screens/full_screen_example.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new ExampleAppBar(
            title: "Photo View"
          ),
          new Container(
            padding: EdgeInsets.all(20.0),
            child: new Text(
              "See bellow examples of some of the most common photo view usage cases",
              style: const TextStyle(
                fontSize: 18.0
              ),
            ),
          ),
          new Expanded(
            child: new ListView(
              children: <Widget>[
                this._buildItem(context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenExample(),
                        ),
                      );
                    },
                    text: "Full screen"
                ),
                this._buildItem(context,
                    onPressed: () {},
                    text: "Part of the screen"
                ),
                this._buildItem(context,
                    onPressed: () {},
                    text: "Different Providers"
                ),

                this._buildItem(context,
                    text: "Hero animation (TODO)"
                ),
                this._buildItem(context,
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
      padding: EdgeInsets.symmetric(
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
